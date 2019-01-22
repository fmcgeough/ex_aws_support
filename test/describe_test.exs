defmodule DescribeTest do
  use ExUnit.Case

  test "describe_services" do
    op = ExAws.Support.describe_services()

    assert op.data == %{"language" => "en", "serviceCodeList" => []}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeServices"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_cases" do
    op =
      ExAws.Support.describe_cases(after_time: "2018-12-01T01:00", include_resolved_cases: true)

    assert op.data == %{"afterTime" => "2018-12-01T01:00", "includeResolvedCases" => true}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeCases"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_communications basic" do
    op = ExAws.Support.describe_communications("case-12345678910-2013-c4c1d2bf33c5cf47")

    assert op.data == %{"caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeCommunications"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_communications with optional data" do
    op =
      ExAws.Support.describe_communications("case-12345678910-2013-c4c1d2bf33c5cf47",
        after_time: "2018-12-01T01:00",
        max_results: 10
      )

    assert op.data == %{
             "caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47",
             "afterTime" => "2018-12-01T01:00",
             "maxResults" => 10
           }

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeCommunications"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_attachment" do
    op = ExAws.Support.describe_attachment("Test")

    assert op.data == %{"attachmentId" => "Test"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeAttachment"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_trusted_advisor_checks" do
    op = ExAws.Support.describe_trusted_advisor_checks()
    assert op.data == %{"language" => "en"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorChecks"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_severity_levels" do
    op = ExAws.Support.describe_severity_levels()
    assert op.data == %{"language" => "en"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeSeverityLevels"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_trusted_advisor_check_summaries" do
    ids = ["TestID1", "TestID2"]
    op = ExAws.Support.describe_trusted_advisor_check_summaries(ids)
    assert op.data == %{"checkIds" => ["TestID1", "TestID2"]}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorCheckSummaries"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "refresh_trusted_advisor_check" do
    op = ExAws.Support.refresh_trusted_advisor_check("CheckId")
    assert op.data == %{"checkId" => "CheckId"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.RefreshTrustedAdvisorCheck"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_trusted_advisor_check_refresh_statuses" do
    ids = ["TestID1", "TestID2"]
    op = ExAws.Support.describe_trusted_advisor_check_refresh_statuses(ids)
    assert op.data == %{"checkIds" => ["TestID1", "TestID2"]}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorCheckRefreshStatuses"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  test "describe_trusted_advisor_check_result" do
    id = "TestId1"
    op = ExAws.Support.describe_trusted_advisor_check_result(id)
    assert op.data == %{"language" => "en", "checkId" => id}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorCheckResult"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end
end
