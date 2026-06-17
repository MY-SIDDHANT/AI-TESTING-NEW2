# LAQ360 CSV Extract - Test Coverage Summary

## Epic: AS-7970 - Envisia LAQ360 CSV Extract

Generated: 2026-06-15

---

## Test Case Files

| Ticket | File | Test Cases |
|--------|------|------------|
| AS-8175 | [AS-8175-test-cases.csv](AS-8175-test-cases.csv) | 25 |
| AS-8174 | [AS-8174-test-cases.csv](AS-8174-test-cases.csv) | 25 |
| AS-8173 | [AS-8173-test-cases.csv](AS-8173-test-cases.csv) | 25 |

---

## Coverage by Ticket

### AS-8175: E2E Testing for LAQ360 CSV Extract Through Admin Portal

| Scenario Type | Count |
|---------------|-------|
| Positive Scenarios | 8 |
| Negative Scenarios | 4 |
| Boundary Cases | 2 |
| Edge Cases | 2 |
| Security Cases | 3 |
| UI Validation Cases | 2 |
| Workflow Cases | 1 |
| Error Handling Cases | 2 |
| Data Validation Cases | 1 |
| **Total** | **25** |

### AS-8174: Define the CSV Report Structure Template

| Scenario Type | Count |
|---------------|-------|
| Positive Scenarios | 6 |
| Negative Scenarios | 2 |
| Boundary Cases | 2 |
| Edge Cases | 2 |
| Data Validation Cases | 10 |
| API Validation Cases | 2 |
| Workflow Cases | 1 |
| Error Handling Cases | 1 |
| Security Cases | 1 |
| **Total** | **25** |

### AS-8173: Analyze the Expected CSV Extract File (Dev Only)

| Scenario Type | Count |
|---------------|-------|
| Positive Scenarios | 8 |
| Negative Scenarios | 1 |
| Edge Cases | 2 |
| Data Validation Cases | 10 |
| API Validation Cases | 1 |
| Workflow Cases | 1 |
| Security Cases | 1 |
| **Total** | **25** |

---

## Overall Coverage Summary

| Metric | Count |
|--------|-------|
| Total Positive Test Cases | 22 |
| Total Negative Test Cases | 7 |
| Total Boundary Cases | 4 |
| Total Edge Cases | 6 |
| Total API Validation Cases | 3 |
| Total Data Validation Cases | 21 |
| Total Security Cases | 5 |
| Total UI Validation Cases | 2 |
| Total Workflow Cases | 3 |
| Total Error Handling Cases | 3 |
| **Grand Total Test Cases** | **75** |
| **Estimated Coverage** | **~85%** |

*Note: Coverage limited by requirement ambiguity. See Questions for BA section below.*

---

## Questions for Business Analyst

### AS-8175 (E2E Testing)

1. **Admin Portal Access**: What are the specific user roles/permissions required to create projects and generate LAQ360 reports?
2. **CSV Extract Clarification**: The ticket mentions "CSV extract to be clarified" - what is the specific trigger/mechanism for CSV extract generation?
3. **Environment Parity**: Are Test and Stage environments expected to have identical configurations and data schemas?
4. **Participant Limits**: What are the minimum and maximum number of self-raters, raters, and leaders that can be assigned to a single LAQ360 project?
5. **Report Consistency**: What specific metrics/scores should be compared to validate "scoring & reporting is consistent with Research Team & Data Team"?
6. **Documentation Format**: What format should be used to "document the results"? Is there a standard template?
7. **Notification Method**: How should the PO be notified - email, Jira comment, specific channel?

### AS-8174 (CSV Report Structure)

1. **Column Specification**: Can you provide the complete list of expected column names with their data types, formats, and constraints?
2. **Reference File Access**: Is the HSI_AssessmentSummary_Envisia_20260601000507.xlsx file the authoritative source for column structure?
3. **Aggregation Query Scope**: Which specific collections/APIs beyond "assessments collection within score sets" need to be queried?
4. **CSV Attachment Destination**: Where should the CSV attachment be stored/sent after generation (S3, email, Snowflake)?
5. **Encoding Requirements**: What character encoding standard should be used for the CSV (UTF-8, ASCII, other)?
6. **Date Format Standard**: What date/time format should be used in the CSV (ISO 8601, custom format)?
7. **Null Value Handling**: How should null/empty values be represented in the CSV (empty string, "NULL", "N/A")?

### AS-8173 (Analysis - Dev Only)

1. **Scope Clarification**: The ticket is marked "Dev Only" - does this mean QA should not test this or just that testing is development-environment only?
2. **Analysis Deliverables**: What specific documentation artifacts are expected as output from the analysis?
3. **JSON File Location**: Where is the current Envisia JSON file located that needs to be evaluated for updates?
4. **Backend Changes Authority**: Who approves backend changes identified during analysis?
5. **Research Team Contact**: Who is the Research Team point of contact for validating scoring & reporting requirements?
6. **Keith's File**: What is the status of the file Keith was supposed to share? Is this a blocker for analysis?
7. **Scoring Ownership**: What does "Envisia to own scoring & reporting" specifically entail - calculation logic, data storage, or both?
8. **Snowflake Schema**: Can you provide the current Snowflake schema used by Anureka's Data Team for comparison?

### Cross-Ticket Questions

1. **Dependency Chain**: What is the dependency order between AS-8173, AS-8174, and AS-8175? Can testing proceed in parallel?
2. **Test Data Availability**: Is there existing test data for LAQ360 assessments, or does new data need to be created?
3. **Integration Timeline**: What is the expected timeline for Envisia integration completion?
4. **Rollback Plan**: If discrepancies are found, what is the escalation and resolution process?

---

## Test Execution Recommendations

### Priority Order
1. **High Priority First**: Execute all High priority test cases before Medium/Low
2. **Positive Before Negative**: Validate happy paths before error scenarios
3. **Ticket Sequence**: AS-8173 → AS-8174 → AS-8175 (based on dependency analysis)

### Environment Requirements
- Access to Admin Portal (Test and Stage environments)
- LAQ360 assessment configuration
- Test participant accounts (self-raters, raters, leaders)
- Reference file: HSI_AssessmentSummary_Envisia_20260601000507.xlsx
- Envisia system access for score comparison

### Test Data Setup
- Create at least 3 LAQ360 projects with varying participant counts
- Complete full assessment cycles for report generation testing
- Include edge case data (special characters, maximum participants)
