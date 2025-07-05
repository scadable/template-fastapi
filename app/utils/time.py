"""
This file is incharge of global time related functions
"""

from datetime import datetime, timezone


def utc_now() -> datetime:
    """
    Return the current UTC time as an aware datetime object.
    """
    return datetime.now(timezone.utc)
