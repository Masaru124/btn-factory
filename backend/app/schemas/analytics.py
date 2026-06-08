from pydantic import BaseModel


class Point(BaseModel):
    label: str
    value: float


class AnalyticsSeries(BaseModel):
    title: str
    points: list[Point]
