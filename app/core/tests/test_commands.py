"""
    Test custom Django management commands.
"""
from unittest.mock import patch, MagicMock

from psycopg2 import OperationalError as Psycopg2OpError

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    # check method from Command is patched
    # check => "patched_check" (by patch module)
    def test_wait_for_db_ready(self, patched_check: MagicMock):
        """Test waiting for db if db ready."""
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check: MagicMock):
        """Test waiting for db when getting OperationError."""
        # raise Psycopg2OpError twice,
        # then raise OperationalError 3 times
        # then return True for 6th times (means OK)
        patched_check.side_effect = [Psycopg2OpError] * 2 + [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
