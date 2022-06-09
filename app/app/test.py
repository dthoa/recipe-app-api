"""
Unit test
"""

from django.test import SimpleTestCase

from app import calc


class CalcTest(SimpleTestCase):
    """Test the calc module."""

    def test_add_number(self):
        """Test adding numbers together"""
        res = calc.add(10, 5)
        self.assertEqual(res, 15)

    def test_subtract_number(self):
        """Test subtracting numbers"""
        res = calc.subtract(10, 5)
        self.assertEqual(res, 5)
