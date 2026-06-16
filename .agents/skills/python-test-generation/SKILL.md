---
name: python-test-generation
description: Generate tests for python projects
disable-model-invocation: false
---

# Skill: Writing Effective Python Tests

Expert guidance for generating, refactoring, and optimizing Python test suites using pytest and test-driven development (TDD) best practices.

## Core Principles

* **pytest Only**: Use pytest exclusively instead of the legacy standard library `unittest` module.
* **AAA Pattern**: Enforce the Arrange-Act-Assert structure in every generated test.
* **Isolated State**: Ensure tests remain independent; never let state leak between test runs.
* **Descriptive Naming**: Test names must explicitly declare the scenario and expected outcome.

## 1. Test Architecture & Directory Structure
Save all test suites within a dedicated `./tests/` root directory to keep the business logic clean.

```text
my_project/
│
├── src/
│   └── app.py
└── tests/
    ├── __init__.py
    ├── conftest.py
    └── test_app.py
```

## 2. Naming Conventions
Enforce automated test discovery by using strict prefix patterns:
* **Test Files**: Must use the `test_*.py` pattern (e.g., `test_authentication.py`).
* **Test Functions**: Must use the `test_*` pattern (e.g., `test_login_fails_with_invalid_password`).

## 3. Implementation Patterns

### Arrange-Act-Assert (AAA)
Structure tests into three distinct phases separated by single blank lines:
```python
def test_calculate_total_adds_tax():
    # Arrange
    price = 100.00
    tax_rate = 0.15
    
    # Act
    result = calculate_total(price, tax_rate)
    
    # Assert
    assert result == 115.00
```

### Pytest Fixtures
Abstract reusable data setup and cleanup into local fixtures inside `conftest.py`:
```python
import pytest

@pytest.fixture
def sample_user():
    return {"id": 1, "role": "member", "active": True}

def test_user_is_active_by_default(sample_user):
    assert sample_user["active"] is True
```

### Parametrization
Consolidate repetitive test cases evaluating multi-input sets to minimize code duplication:
```python
import pytest

@pytest.mark.parametrize(
    "input_val, expected", 
    [
        (2, True),
        (3, False),
        (4, True)
    ]
)
def test_is_even(input_val, expected):
    assert is_even(input_val) == expected
```

### Exception & Error Testing
Verify that your business logic correctly throws expected exceptions under pressure scenarios:
```python
import pytest

def test_divide_by_zero_raises_value_error():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)
```

### Mocking External Dependencies
Isolate unit tests by mocking databases, third-party network APIs, and slow file system IO Operations:
```python
def test_fetch_profile_calls_api(monkeypatch):
    class MockResponse:
        def json(self): return {"name": "Alice"}
        
    monkeypatch.setattr("requests.get", lambda url: MockResponse())
    assert fetch_profile(123) == {"name": "Alice"}
```

## 4. Execution Commands
Always evaluate your coverage and execute test suites via `uv`:
* Run all tests: `uv run pytest`
* Fail on first error: `uv run pytest -x`
* Run a specific file: `uv run pytest tests/test_app.py`
* Run matching pattern: `uv run pytest -k "login"`
