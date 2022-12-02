import prophet
import nevergrad
import pandas as pd

def main():
    year_list = [2021, 2022]
    out = prophet.make_holidays.make_holidays_df(
        year_list=year_list, country='JP'
    )
    return out