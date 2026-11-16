"""Button Factory MES - Windows Startup Manager.

Configures automatic background startup on Windows boot / user login:
- Registers elevated Windows Task Scheduler task: ButtonFactoryMES_AutoStart
- Creates fallback shortcut in Windows Startup folder (shell:startup)
- Supports Nginx (default) or IIS server mode
- Removes all startup tasks/shortcuts cleanly when requested
"""

import os
import subprocess
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(SCRIPT_DIR)
PROJECT_ROOT = os.path.dirname(BACKEND_DIR)
TASK_NAME = 'ButtonFactoryMES_AutoStart'
LNK_NAME = 'ButtonFactoryMES.lnk'


def get_startup_dir() -> str:
    appdata = os.environ.get('APPDATA') or os.path.expanduser('~')
    return os.path.join(appdata, r'Microsoft\Windows\Start Menu\Programs\Startup')


def create_vbs_shortcut(shortcut_path: str, target_path: str, arguments: str, working_dir: str) -> bool:
    """Create Windows .lnk shortcut via temporary VBScript."""
    vbs_path = os.path.join(os.environ.get('TEMP', '.'), '_btn_factory_mklnk.vbs')
    script = f'''Set ws = CreateObject("WScript.Shell")
Set lnk = ws.CreateShortcut("{shortcut_path}")
lnk.TargetPath = "{target_path}"
lnk.Arguments = "{arguments}"
lnk.WorkingDirectory = "{working_dir}"
lnk.WindowStyle = 7
lnk.Save
'''
    try:
        with open(vbs_path, 'w', encoding='utf-8') as f:
            f.write(script)
        subprocess.run(['cscript', '//nologo', vbs_path], check=True, capture_output=True)
        if os.path.exists(vbs_path):
            os.remove(vbs_path)
        return os.path.exists(shortcut_path)
    except Exception as e:
        print(f" [WARN] Could not create startup shortcut via VBS: {e}")
        if os.path.exists(vbs_path):
            try:
                os.remove(vbs_path)
            except OSError:
                pass
        return False


def add_to_startup(server_type: str = 'nginx') -> bool:
    """Add Button Factory MES to Windows Startup."""
    server_type = server_type.lower().strip()
    if server_type in ('iis', '2'):
        target_bat = os.path.join(PROJECT_ROOT, 'Launch_With_IIS.bat')
        server_name = 'IIS Reverse Proxy'
    elif server_type in ('button_factory', 'buttonfactory', 'triple', 'tunnel', '3'):
        target_bat = os.path.join(PROJECT_ROOT, 'Launch_Button_Factory.bat')
        server_name = 'Button Factory (FastAPI + Cloudflare/ngrok Tunnels)'
    else:
        target_bat = os.path.join(PROJECT_ROOT, 'Launch_With_Nginx.bat')
        server_name = 'Nginx Reverse Proxy'

    if not os.path.exists(target_bat):
        print(f" [ERROR] Launcher file not found at: {target_bat}")
        return False

    print("=" * 70)
    print("  BUTTON FACTORY MES - ADD TO WINDOWS STARTUP")
    print("=" * 70)
    print(f" Mode        : {server_name}")
    print(f" Target File : {target_bat}")
    print(f" Arguments   : --startup")
    print("-" * 70)

    # 1. Register with Windows Task Scheduler (Elevated logon task)
    sch_ok = False
    cmd = [
        'schtasks', '/create',
        '/tn', TASK_NAME,
        '/tr', f'"{target_bat}" --startup',
        '/sc', 'onlogon',
        '/rl', 'highest',
        '/f',
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            sch_ok = True
            print(f" [PASS] Windows Task Scheduler task '{TASK_NAME}' registered successfully.")
            print("        Runs automatically with highest permissions on every boot/logon.")
        else:
            print(f" [NOTE] Task Scheduler registration returned non-zero (may need Admin privileges):")
            print(f"        {res.stderr.strip() or res.stdout.strip()}")
    except Exception as e:
        print(f" [WARN] Error executing schtasks: {e}")

    # 2. Create User Startup Folder Shortcut
    startup_dir = get_startup_dir()
    os.makedirs(startup_dir, exist_ok=True)
    shortcut_path = os.path.join(startup_dir, LNK_NAME)
    lnk_ok = create_vbs_shortcut(
        shortcut_path=shortcut_path,
        target_path=target_bat,
        arguments='--startup',
        working_dir=PROJECT_ROOT,
    )
    if lnk_ok:
        print(f" [PASS] Windows Startup folder shortcut created: {shortcut_path}")

    print("=" * 70)
    if sch_ok or lnk_ok:
        print(f" SUCCESS: Button Factory MES will start automatically with {server_name} on reboot!")
        print("          Automated database and media hourly backups will run in background.")
        print("=" * 70)
        return True
    else:
        print(" FAILED: Could not register startup task or shortcut.")
        print("=" * 70)
        return False


def remove_from_startup() -> bool:
    """Remove Button Factory MES from Windows Startup."""
    print("=" * 70)
    print("  BUTTON FACTORY MES - REMOVE FROM WINDOWS STARTUP")
    print("=" * 70)

    # 1. Delete scheduled task
    cmd = ['schtasks', '/delete', '/tn', TASK_NAME, '/f']
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            print(f" [PASS] Windows Task Scheduler task '{TASK_NAME}' deleted.")
        else:
            print(f" [INFO] Scheduled task '{TASK_NAME}' was not registered or already removed.")
    except Exception as e:
        print(f" [WARN] Could not run schtasks: {e}")

    # 2. Remove shortcut from user startup folder
    startup_dir = get_startup_dir()
    shortcut_path = os.path.join(startup_dir, LNK_NAME)
    if os.path.exists(shortcut_path):
        try:
            os.remove(shortcut_path)
            print(f" [PASS] Removed shortcut from User Startup folder: {shortcut_path}")
        except Exception as e:
            print(f" [WARN] Could not delete startup shortcut: {e}")
    else:
        print(f" [INFO] No shortcut found in User Startup folder.")

    # 3. Check All Users Startup folder
    progdata = os.environ.get('ProgramData')
    if progdata:
        common_lnk = os.path.join(progdata, r'Microsoft\Windows\Start Menu\Programs\Startup', LNK_NAME)
        if os.path.exists(common_lnk):
            try:
                os.remove(common_lnk)
                print(f" [PASS] Removed shortcut from System Startup folder.")
            except Exception:
                pass

    print("=" * 70)
    print(" SUCCESS: Button Factory MES has been removed from Windows Startup.")
    print(" The server will no longer launch automatically on boot.")
    print("=" * 70)
    return True


if __name__ == '__main__':
    action = sys.argv[1].lower() if len(sys.argv) > 1 else 'add'
    server = sys.argv[2].lower() if len(sys.argv) > 2 else 'nginx'

    if action in ('remove', 'delete', 'uninstall'):
        remove_from_startup()
    else:
        add_to_startup(server)
