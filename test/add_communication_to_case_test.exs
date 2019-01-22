defmodule AddCommunicationToCaseTest do
  use ExUnit.Case

  test "request format" do
    case_id = "case-12345678910-2013-c4c1d2bf33c5cf47"
    attachment_set_id = "attachment_set_id"
    communication_body = "Important text"
    cc_email_addresses = ["test@test.com", "xyz@test.com"]

    op =
      ExAws.Support.add_communication_to_case(
        case_id,
        attachment_set_id,
        communication_body,
        cc_email_addresses
      )

    assert op.data == %{
             "attachmentSetId" => "attachment_set_id",
             "caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47",
             "ccEmailAddresses" => ["test@test.com", "xyz@test.com"],
             "communicationBody" => "Important text"
           }

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.AddCommunicationToCase"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end
end
