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
    elif server_type in ('cloudflare', 'cloudflared', 'cloudflare_tunnel', '3'):
        target_bat = os.path.join(PROJECT_ROOT, 'Launch_With_Cloudflare_Tunnel.bat')
        server_name = 'Cloudflare Tunnel (DuckDNS Host Mode)'
    elif server_type in ('button_factory', 'buttonfactory', 'triple', 'tunnel', '4'):
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
    """Remove Button Factory MES from Windows Startup cleanly and comprehensively."""
    print("=" * 70)
    print("  BUTTON FACTORY MES - REMOVE FROM WINDOWS STARTUP")
    print("=" * 70)

    removed_items = 0

    # 1. Delete scheduled tasks
    known_tasks = [
        TASK_NAME,
        'ButtonFactoryMES',
        'ButtonFactory_AutoStart',
        'ButtonFactory',
        'Button_Factory_MES',
        'Button_Factory_AutoStart',
        'Launch_Button_Factory',
    ]

    for tn in known_tasks:
        try:
            res = subprocess.run(['schtasks', '/delete', '/tn', tn, '/f'], capture_output=True, text=True)
            if res.returncode == 0:
                print(f" [PASS] Windows Task Scheduler task '{tn}' deleted.")
                removed_items += 1
            elif "Access is denied" in (res.stderr or ''):
                print(f" [WARN] Task '{tn}' requires Administrator privileges to delete!")
        except Exception:
            pass

    # Query all scheduled tasks to catch any tasks containing our project paths or names
    try:
        res = subprocess.run(['schtasks', '/query', '/fo', 'CSV', '/v'], capture_output=True, text=True, errors='ignore')
        if res.returncode == 0:
            for line in res.stdout.splitlines():
                line_lower = line.lower()
                if any(kw in line_lower for kw in ('buttonfactory', 'btn-factory', 'btn_factory', 'launch_button_factory', 'launch_with_nginx', 'launch_with_iis', 'launch_with_cloudflare')):
                    parts = [p.strip('"') for p in line.split('","')]
                    if parts and parts[0] != 'TaskName':
                        task_name = parts[0].lstrip('\\')
                        del_res = subprocess.run(['schtasks', '/delete', '/tn', task_name, '/f'], capture_output=True, text=True)
                        if del_res.returncode == 0:
                            print(f" [PASS] Removed discovered scheduled task: '{task_name}'")
                            removed_items += 1
    except Exception:
        pass

    # 2. Clean User and System Startup folders
    startup_dirs = [get_startup_dir()]
    progdata = os.environ.get('ProgramData')
    if progdata:
        startup_dirs.append(os.path.join(progdata, r'Microsoft\Windows\Start Menu\Programs\Startup'))

    for s_dir in startup_dirs:
        if not os.path.exists(s_dir):
            continue
        try:
            for fname in os.listdir(s_dir):
                fpath = os.path.join(s_dir, fname)
                fname_lower = fname.lower()
                should_remove = False

                # Direct filename match
                if any(kw in fname_lower for kw in ('buttonfactory', 'btn_factory', 'btn-factory', 'launch_button_factory', 'launch_with_', 'start_factory_server')):
                    should_remove = True
                elif fname_lower.endswith('.lnk'):
                    # Check target path of shortcut
                    try:
                        ps_cmd = f"(New-Object -ComObject WScript.Shell).CreateShortcut('{fpath}').TargetPath"
                        target = subprocess.check_output(['powershell', '-NoProfile', '-Command', ps_cmd], text=True, errors='ignore').strip()
                        if target and os.path.normpath(PROJECT_ROOT).lower() in os.path.normpath(target).lower():
                            should_remove = True
                    except Exception:
                        pass

                if should_remove and os.path.exists(fpath):
                    try:
                        os.remove(fpath)
                        print(f" [PASS] Removed startup shortcut: {fpath}")
                        removed_items += 1
                    except Exception as e:
                        print(f" [WARN] Could not delete '{fname}': {e}")
        except Exception as e:
            print(f" [WARN] Could not inspect startup directory '{s_dir}': {e}")

    # 3. Clean Windows Registry Run keys
    try:
        import winreg
        hives = [
            (winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Run", "HKCU"),
            (winreg.HKEY_LOCAL_MACHINE, r"Software\Microsoft\Windows\CurrentVersion\Run", "HKLM"),
        ]
        for hive, subkey, hive_name in hives:
            try:
                key = winreg.OpenKey(hive, subkey, 0, winreg.KEY_ALL_ACCESS)
                to_delete = []
                i = 0
                while True:
                    try:
                        val_name, val_data, _ = winreg.EnumValue(key, i)
                        val_str = f"{val_name} {val_data}".lower()
                        if any(kw in val_str for kw in ('buttonfactory', 'btn-factory', 'btn_factory', 'launch_button_factory')):
                            to_delete.append(val_name)
                        i += 1
                    except OSError:
                        break
                for val_name in to_delete:
                    winreg.DeleteValue(key, val_name)
                    print(f" [PASS] Removed registry startup entry: {hive_name}\\{val_name}")
                    removed_items += 1
                winreg.CloseKey(key)
            except Exception:
                pass
    except Exception:
        pass

    # 4. Stop any currently active server processes
    print("-" * 70)
    print(" Stopping any running background server processes...")
    try:
        subprocess.run('taskkill /F /FI "WINDOWTITLE eq Backend Server*"', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run('taskkill /F /FI "WINDOWTITLE eq *Auto Backup*"', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run('taskkill /F /FI "WINDOWTITLE eq *FastAPI*"', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run('taskkill /F /IM uvicorn.exe', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run('taskkill /F /IM caddy.exe', shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    print("=" * 70)
    if removed_items > 0:
        print(f" SUCCESS: Removed {removed_items} startup task(s)/shortcut(s).")
    else:
        print(" SUCCESS: No remaining Button Factory MES startup entries found.")
    print(" The server will no longer launch automatically on Windows boot or restart.")
    print("=" * 70)
    return True


if __name__ == '__main__':
    action = sys.argv[1].lower() if len(sys.argv) > 1 else 'add'
    server = sys.argv[2].lower() if len(sys.argv) > 2 else 'nginx'

    if action in ('remove', 'delete', 'uninstall'):
        remove_from_startup()
    else:
        add_to_startup(server)
