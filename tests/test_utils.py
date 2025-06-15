import pytest
# Assuming calculate_name_numerology_number is in backend_server.py
# If it's in a different utils file, adjust the import.
from backend_server import calculate_name_numerology_number, NUMEROLOGY_LETTER_VALUES

def test_calculate_name_numerology_number_simple():
    assert calculate_name_numerology_number("A") == 1
    assert calculate_name_numerology_number("J") == 1
    assert calculate_name_numerology_number("S") == 1

def test_calculate_name_numerology_number_word():
    # AMETHYST = 1+4+5+2+8+7+1+2 = 30 = 3+0 = 3
    assert calculate_name_numerology_number("Amethyst") == 3
    # QUARTZ = 8+3+1+9+2+8 = 31 = 3+1 = 4
    assert calculate_name_numerology_number("Quartz") == 4
    # RUBY = 9+3+2+7 = 21 = 2+1 = 3
    assert calculate_name_numerology_number("Ruby") == 3

def test_calculate_name_numerology_number_empty_string():
    assert calculate_name_numerology_number("") == 0

def test_calculate_name_numerology_number_with_spaces():
    # ROSE QUARTZ
    # ROSE = 9+6+1+5 = 21 = 3
    # QUARTZ = 8+3+1+9+2+8 = 31 = 4
    # For "Rose Quartz", the current function would sum continuous letters.
    # "rosequartz" = 9+6+1+5+8+3+1+9+2+8 = 52 = 7.
    # If spaces should be ignored and letters summed:
    assert calculate_name_numerology_number("Rose Quartz") == 7
    # If words are summed separately then their results summed and reduced:
    # This would require a change in function logic. Current logic is continuous.
    # For now, test current behavior.

    assert calculate_name_numerology_number(" Two Words ") == calculate_name_numerology_number("twowords")


def test_calculate_name_numerology_number_with_invalid_chars():
    # Numbers and symbols are ignored (value 0)
    assert calculate_name_numerology_number("Amethyst123!@#") == 3
    assert calculate_name_numerology_number("123 !@#") == 0

def test_calculate_name_numerology_number_long_reduction():
    # Example needing multiple reduction steps
    # Assuming a hypothetical name that sums to e.g. 19 -> 10 -> 1
    # Or a name that sums to 29 -> 11 -> 2 (current logic, not master numbers)
    # Create a string that sums to a known multi-reduction value.
    # e.g. 'iiii' -> 9+9+9+9 = 36 -> 3+6 = 9
    assert calculate_name_numerology_number("iiii") == 9
    # 'iiiii' -> 9*5 = 45 -> 9
    assert calculate_name_numerology_number("iiiii") == 9
    # 'siiii' -> 1 + 9*4 = 37 -> 10 -> 1
    assert calculate_name_numerology_number("siiii") == 1
    # 'ssiiii' -> 1*2 + 9*4 = 2 + 36 = 38 -> 11 -> 2
    assert calculate_name_numerology_number("ssiiii") == 2

def test_ensure_numerology_map_present():
    assert len(NUMEROLOGY_LETTER_VALUES) > 0
    assert NUMEROLOGY_LETTER_VALUES['a'] == 1
    assert NUMEROLOGY_LETTER_VALUES['z'] == 8

# Test case where name results in 0 before reduction loop (e.g. only invalid chars)
def test_calculate_name_numerology_number_zero_sum_before_reduction():
    assert calculate_name_numerology_number("1-!") == 0

# Test case where name consists only of characters not in map (if any were added to map)
# Current map covers all a-z, so this isn't directly testable unless map changes.
# def test_calculate_name_numerology_number_all_unknown_chars():
#    # Assuming '!' is not in map and has value 0
#    assert calculate_name_numerology_number("!!!!") == 0
