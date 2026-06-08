from datetime import date

from pydantic import BaseModel


class DateRangeRequest(BaseModel):
    start_date: date
    end_date: date


class MetricValue(BaseModel):
    label: str
    value: float
    unit: str | None = None


class ReportSummary(BaseModel):
    title: str
    metrics: list[MetricValue]
