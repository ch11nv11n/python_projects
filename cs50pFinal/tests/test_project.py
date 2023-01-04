import pytest
from datetime import date
from project import quitApplication, dateClean, displayMenu

def test_quitApplication():
    with pytest.raises(SystemExit) as e:
        quitApplication()
        assert e.type == SystemExit
        assert e.value.code == 1


def test_dateClean():
    assert dateClean('12.21') == date(date.today().year,12,21) # if formatted as 2 digit day and month seperated by .
    assert dateClean('2022') == date(date.today().year,1,1) # # if just year
    assert dateClean('December') == date(date.today().year,12,1) # else convert month name to month num


def test_displayMenu():
    assert displayMenu() == '''
======================================================
        Google Calendar Shoe Release Scheduler
======================================================
  [1] View All Releases
  [2] View Jordan Releases
  [3] View Yeezy Releases
  [4] Quit Program
        '''