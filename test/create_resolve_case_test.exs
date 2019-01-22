defmodule CreateResolveCaseTest do
  use ExUnit.Case

  test "create minimal case" do
    op = ExAws.Support.create_case("Subject", "Communication Body - Details Here")

    assert op.data == %{
             "communicationBody" => "Communication Body - Details Here",
             "subject" => "Subject"
           }

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.CreateCase"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end

  # service_code: these can be obtained by calling describe_services(). It returns
  # {:ok %{"results" => services}} where services is a List and each element is a map.
  # Here's an example for MariaDB RDS service:
  #
  # %{
  #   "__type" => "Service",
  #   "categories" => [
  #     %{"code" => "other", "name" => "Other"},
  #     %{"code" => "apis", "name" => "APIs"},
  #     %{"code" => "connectivity", "name" => "Connectivity"},
  #     %{"code" => "migration-issue", "name" => "Migration Issue"},
  #     %{"code" => "feature-request", "name" => "Feature Request"},
  #     %{"code" => "database-issue", "name" => "Database Issue"},
  #     %{"code" => "general-guidance", "name" => "General Guidance"}
  #   ],
  #   "code" => "amazon-relational-database-service-mariadb",
  #   "name" => "Relational Database Service (MariaDB)"
  # }
  # %{"code" => "the code for this service"}
  #
  # severity_levels: Here's a sample of whast the output from
  # describe_severity_levels might look like
  #
  # %{
  #    "severityLevels" => [
  #     %{"code" => "low", "name" => "Low"},
  #     %{"code" => "normal", "name" => "Normal"},
  #     %{"code" => "high", "name" => "High"},
  #     %{"code" => "urgent", "name" => "Urgent"},
  #     %{"code" => "critical", "name" => "Critical"}
  #   ]
  # }
  test "create case with more options" do
    op =
      ExAws.Support.create_case("Problem with our MariaDB", "Cannot connect to XYZ",
        service_code: "amazon-relational-database-service-mariadb",
        severity_code: "urgent",
        issue_type: "technical",
        category_code: "connectivity",
        language: "en"
      )

    assert op.data == %{
             "categoryCode" => "connectivity",
             "communicationBody" => "Cannot connect to XYZ",
             "issueType" => "technical",
             "language" => "en",
             "serviceCode" => "amazon-relational-database-service-mariadb",
             "severityCode" => "urgent",
             "subject" => "Problem with our MariaDB"
           }
  end

  test "resolve case" do
    op = ExAws.Support.resolve_case("TestCaseId")
    assert op.data == %{"caseId" => "TestCaseId"}

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.ResolveCase"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end
end
