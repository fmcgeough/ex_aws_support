defmodule ExAws.Support do
  @moduledoc """
    Operations for AWS Support API
  """

  # version of the AWS API
  @version "20130415"
  @namespace "AWSSupport"

  @type attachment :: [data: binary, file_name: binary]
  @type attachments :: [attachment, ...]
  @type create_case_opts :: [
          attachment_set_id: binary,
          category_code: binary,
          cc_email_addresses: [binary, ...],
          issue_type: binary,
          language: binary,
          service_code: binary,
          severity_code: binary
        ]

  @type describe_cases_opts :: [
          after_time: binary,
          before_time: binary,
          case_id_list: [binary, ...],
          display_id: binary,
          include_communications: boolean,
          include_resolved_cases: boolean,
          language: binary,
          max_results: integer,
          next_token: binary
        ]
  @type describe_communications_opts :: [
          after_time: binary,
          before_time: binary,
          max_results: integer,
          next_token: binary
        ]
  @doc """
    Adds one or more attachments to an attachment set

    If an attachment_set_id is not specified, a new attachment set is created,
    and the ID of the set is returned in the response. If an attachment_set_id
    is specified, the attachments are added to the specified set, if it exists.

    An attachment set is a temporary container for attachments that are to be
    added to a case or case communication. The set is available for one hour
    after it is created; the expiryTime returned in the response indicates when
    the set expires. The maximum number of attachments in a set is 3, and the
    maximum size of any attachment in the set is 5 MB.

  """
  @spec add_attachments_to_set(attachments :: attachments) :: ExAws.Operation.JSON.t()
  @spec add_attachments_to_set(attachments :: attachments, attachment_set_id :: binary | nil) ::
          ExAws.Operation.JSON.t()
  def add_attachments_to_set(attachments, attachment_set_id \\ nil) when is_list(attachments) do
    case attachment_set_id do
      nil -> %{}
      val -> %{"attachmentSetId" => val}
    end
    |> Map.merge(%{"attachments" => camelize_keyword(attachments)})
    |> request(:add_attachments_to_set)
  end

  @doc """
    Adds additional customer communication to an AWS Support case

    You use the case_id value to identify the case to add communication to.
    You can list a set of email addresses to copy on the communication using
    the cc_email_addresses value. The communication_body value contains the
    text of the communication.

    The response indicates the success or failure of the request

  ## Parameters

    * attachment_set_id - The ID of a set of one or more attachments for
    the communication to add to the case. Create the set by calling
    `add_attachments_to_set/2`

    * case_id - The AWS Support case ID requested or returned in the call.
    The case ID is an alphanumeric string formatted as shown in this
    example: case-12345678910-2013-c4c1d2bf33c5cf47

    * cc_email_addresses - The email addresses in the CC line of an email to be
    added to the support case. List of Strings. Minimum number of 0 items.
    Maximum number of 10 items.

    * communication_body - The body of an email communication to add to the
    support case. Minimum length of 1. Maximum length of 8000.
  """
  def add_communication_to_case(
        case_id,
        attachment_set_id,
        communication_body,
        cc_email_addresses \\ []
      ) do
    %{
      "caseId" => case_id,
      "attachmentSetId" => attachment_set_id,
      "communicationBody" => communication_body,
      "ccEmailAddresses" => cc_email_addresses
    }
    |> request(:add_communication_to_case)
  end

  @doc """
    Creates a new case in the AWS Support Center

    This operation is modeled on the behavior of the AWS Support Center
    Create Case page. Its parameters require you to specify the following information:

  ## Parameter Descriptions

    * issue_type - The type of issue for the case. You can specify either
    "customer-service" or "technical." If you do not indicate a value, the
    default is "technical." Note: Service limit increases are not supported
    by the Support API; you must submit service limit increase requests in
    Support Center.

    * service_code - The code for an AWS service. You can get the possible
    service_code values by calling `describe_services/2`.

    * category_code - The category for the service defined for the service_code
    value. You also get the category code for a service by calling describe_services.
    Each AWS service defines its own set of category codes.

    * severity_code - A value that indicates the urgency of the case, which in
    turn determines the response time according to your service level agreement
    with AWS Support. You can get the possible severity_code values by calling
    `describe_security_levels/1`. For more information about the meaning of the
    codes, see SeverityLevel and Choosing a Severity.

    * subject - The Subject field on the AWS Support Center Create Case page.

    * communication_body - The Description field on the AWS Support Center Create
    Case page.

    * attachment_set_id - The ID of a set of attachments that has been created by
    using `add_attachments_to_set/2`

    * language - The human language in which AWS Support handles the case.
    English and Japanese are currently supported.

    * cc_email_addresses - The AWS Support Center CC field on the Create Case
    page. You can list email addresses to be copied on any correspondence about the
    case. The account that opens the case is already identified by passing the
    AWS Credentials in the HTTP POST method or in a method or function call from
    one of the programming languages supported by an AWS SDK.

  Note:  To add additional communication or attachments to an existing case,
  use `add_communication_to_case/4`.

  A successful `create_case/3` request returns an AWS Support case number.
  Case numbers are used by the describe_cases operation to retrieve existing
  AWS Support cases.
  """
  @spec create_case(subject :: binary, communication_body :: binary, opts :: create_case_opts) ::
          ExAws.Operation.JSON.t()
  def create_case(subject, communication_body, opts \\ []) do
    opts
    |> camelize_keyword()
    |> Map.merge(%{"subject" => subject, "communicationBody" => communication_body})
    |> request(:create_case)
  end

  @doc """
    Returns the attachment that has the specified ID

    Attachment IDs are generated by the case management system when you
    add an attachment to a case or case communication. Attachment IDs are
    returned in the AttachmentDetails objects that are returned by the
    describe_communications operation
  """
  @spec describe_attachment(attachment_id :: binary) :: ExAws.Operation.JSON.t()
  def describe_attachment(attachment_id) do
    %{"attachmentId" => attachment_id}
    |> request(:describe_attachment)
  end

  @doc """
    Returns a list of cases that you specify by passing one or more case IDs

    In addition, you can filter the cases by date by setting values for the after_time
    and before_time request parameters. You can set values for the include_resolved_cases
    and include_communications request parameters to control how much information is
    returned.

    Case data is available for 12 months after creation. If a case was created more
    than 12 months ago, a request for data might cause an error.

    The response returns the following in JSON format:

    * One or more CaseDetails data types.
    * One or more next_token values, which specify where to paginate the returned
    records represented by the CaseDetails objects.

  ## Parameter Descriptions

  * after_time - The start date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation. String format is:
  YYYY-MM-DDTHH:MM, for example: 2018-12-19T16:40"

  * before_time - The end date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation.

  * case_id_list - A list of ID numbers of the support cases you want returned.
  The maximum number of cases is 100. Note: A case_id in AWS is not the value that
  you see in AWS Support web pages. That is the display_id. Its a unique identifier
  returned when you create a case that includes your account id. The case ID is an
  alphanumeric string formatted as shown in this example:
  "case-12345678910-2013-c4c1d2bf33c5cf47"

  * display_id - This is the 10 digit number show in AWS Support web interface and labeled
  "Case Id"

  * include_resolved_cases - Specifies whether resolved support cases should be included in
  the `describe_cases/1` results. The default is false. If you are not getting data back and you
  expect to, ensure that you are setting this to true.

  * language - The human language in which AWS Support handles the case.
    English and Japanese are currently supported.

  * max_results: The maximum number of results to return before paginating. Valid Range: Minimum
  value of 10. Maximum value of 100.

  * next_token: A resumption point for pagination. Returned by previous describe_cases call as
  "nextToken" in the JSON.
  """
  @spec describe_cases() :: ExAws.Operation.JSON.t()
  @spec describe_cases(opts :: describe_cases_opts) :: ExAws.Operation.JSON.t()
  def describe_cases(opts \\ []) do
    opts
    |> camelize_keyword()
    |> request(:describe_cases)
  end

  @doc """
    Returns communications (and attachments) for one or more support cases

    You can use the after_time and before_time parameters to filter by date.
    You can use the caseId parameter to restrict the results to a particular case.

    Case data is available for 12 months after creation. If a case was created
    more than 12 months ago, a request for data might cause an error.

    You can use the max_results and next_token parameters to control the pagination
    of the result set. Set max_results to the number of cases you want displayed
    on each page, and use next_token to specify the resumption of pagination.

  ## Parameter Descriptions

  * after_time - The start date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation. String format is:
  YYYY-MM-DDTHH:MM, for example: 2018-12-19T16:40"

  * before_time - The end date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation.

  * case_id - Identifies what case you want attachment info for. REQUIRED.

  * max_results - The maximum number of results to return before paginating. Integer.
  Valid Range: Minimum value of 10. Maximum value of 100.

  * next_token - A resumption point for pagination
  """
  @spec describe_communications(case_id :: binary) :: ExAws.Operation.JSON.t()
  @spec describe_communications(case_id :: binary, opts :: describe_communications_opts) ::
          ExAws.Operation.JSON.t()
  def describe_communications(case_id, opts \\ []) do
    opts
    |> camelize_keyword()
    |> Map.merge(%{"caseId" => case_id})
    |> request(:describe_communications)
  end

  @doc """
    Returns the current list of AWS services and a list of service categories
    that applies to each one

    You then use service names and categories in your create_case requests.
    Each AWS service has its own set of categories.

    The service codes and category codes correspond to the values that are
    displayed in the Service and Category drop-down lists on the AWS Support
    Center Create Case page. The values in those fields, however, do not
    necessarily match the service codes and categories returned by the describe_services
    request. Always use the service codes and categories obtained programmatically.
    This practice ensures that you always have the most recent set of service and
    category codes.
  """
  @spec describe_services() :: ExAws.Operation.JSON.t()
  @spec describe_services(language :: binary) :: ExAws.Operation.JSON.t()
  @spec describe_services(language :: binary, service_code_list :: [binary, ...] | []) ::
          ExAws.Operation.JSON.t()
  def describe_services(language \\ "en", service_code_list \\ []) do
    %{"language" => language, "serviceCodeList" => service_code_list}
    |> request(:describe_services)
  end

  @doc """
    Returns the list of severity levels that you can assign to an AWS Support case

    The severity level for a case is also a field in the CaseDetails data type
    included in any `create_case/1` request.

  ## Parameter Descriptions

  language - The ISO 639-1 code for the language in which AWS provides support.
  AWS Support currently supports English ("en") and Japanese ("ja"). Language
  parameters must be passed explicitly for operations that take them.
  """
  @spec describe_severity_levels() :: ExAws.Operation.JSON.t()
  @spec describe_severity_levels(language :: binary) :: ExAws.Operation.JSON.t()
  def describe_severity_levels(language \\ "en") do
    %{"language" => language}
    |> request(:describe_severity_levels)
  end

  @doc """
    Returns the refresh status of the Trusted Advisor checks that have the
    specified check IDs

    Check IDs can be obtained by calling `describe_trusted_advisor_checks/1`.

    Note: Some checks are refreshed automatically, and their refresh statuses
    cannot be retrieved by using this operation. Use of the
    describe_trusted_advisor_check_refresh_statuses operation for these checks
    causes an InvalidParameterValue error.
  """
  @spec describe_trusted_advisor_check_refresh_statuses(check_ids :: binary) ::
          ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_refresh_statuses(check_ids) do
    %{"checkIds" => check_ids}
    |> request(:describe_trusted_advisor_check_refresh_statuses)
  end

  @doc """
    Returns the results of the Trusted Advisor check that has the specified check ID

    Check IDs can be obtained by calling DescribeTrustedAdvisorChecks.

    The response contains a TrustedAdvisorCheckResult object, which contains these
    three objects:

    * TrustedAdvisorCategorySpecificSummary
    * TrustedAdvisorResourceDetail
    * TrustedAdvisorResourcesSummary

    In addition, the response contains these fields:

    * status. The alert status of the check: "ok" (green), "warning" (yellow), "error" (red), or "not_available".
    * timestamp. The time of the last refresh of the check.
    * checkId. The unique identifier for the check.
  """
  @spec describe_trusted_advisor_check_result(check_id :: binary, language :: binary) ::
          ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_result(check_id, language \\ "en") do
    %{"checkId" => check_id, "language" => language}
    |> request(:describe_trusted_advisor_check_result)
  end

  @doc """
    Returns information about all available Trusted Advisor checks, including name,
    ID, category, description, and metadata

    You must specify a language code; English ("en") and Japanese ("ja") are
    currently supported. The response contains a TrustedAdvisorCheckDescription for
    each check.
  """
  @spec describe_trusted_advisor_checks(language :: binary) :: ExAws.Operation.JSON.t()
  def describe_trusted_advisor_checks(language \\ "en") do
    %{"language" => language}
    |> request(:describe_trusted_advisor_checks)
  end

  @doc """
    Returns the summaries of the results of the Trusted Advisor checks
    that have the specified check IDs

    Check IDs can be obtained by calling `describe_trusted_advisor_checks/1`.

    The response contains an array of TrustedAdvisorCheckSummary objects.
  """
  @spec describe_trusted_advisor_check_summaries(check_ids :: [binary, ...]) ::
          ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_summaries(check_ids) do
    %{"checkIds" => check_ids}
    |> request(:describe_trusted_advisor_check_summaries)
  end

  @doc """
    Requests a refresh of the Trusted Advisor check that has the specified check ID

    Check IDs can be obtained by calling `describe_trusted_advisor_checks/1`

    Some checks are refreshed automatically, and they cannot be refreshed by using
    this operation. Use of the `refresh_trusted_advisor_check/1` function for these
    checks causes an InvalidParameterValue error.
  """
  @spec refresh_trusted_advisor_check(check_id :: binary) :: ExAws.Operation.JSON.t()
  def refresh_trusted_advisor_check(check_id) do
    %{"checkId" => check_id}
    |> request(:refresh_trusted_advisor_check)
  end

  @doc """
    Takes a case_id and returns the initial state of the case along with the
    state of the case after the call to resolve_case completed
  """
  @spec resolve_case(case_id :: binary) :: ExAws.Operation.JSON.t()
  def resolve_case(case_id) do
    %{"caseId" => case_id}
    |> request(:resolve_case)
  end

  ####################
  # Helper Functions #
  ####################

  defp request(params, action) do
    action_string = action |> Atom.to_string() |> Macro.camelize()

    %ExAws.Operation.JSON{
      http_method: :post,
      headers: [
        {"x-amz-target", "#{@namespace}_#{@version}.#{action_string}"},
        {"content-type", "application/x-amz-json-1.1"}
      ],
      data: params,
      service: :support
    }
  end

  # The API wants keywords in lower camel case format
  # this function works thru a KeyWord which may have one
  # layer of KeyWord within it and builds a map where keys
  # are in this format.
  #
  # [test: [my_key: "val"]] becomes %{"test" => %{"myKey" => "val"}}
  defp camelize_keyword(a_list) when is_list(a_list) or is_map(a_list) do
    case Keyword.keyword?(a_list) or is_map(a_list) do
      true ->
        a_list
        |> Enum.reduce(%{}, fn {k, v}, acc ->
          k_str =
            case is_atom(k) do
              true ->
                k |> Atom.to_string() |> Macro.camelize() |> decap()

              false ->
                k
            end

          Map.put(acc, k_str, camelize_keyword(v))
        end)

      false ->
        a_list
        |> Enum.reduce([], fn item, acc -> [camelize_keyword(item) | acc] end)
        |> Enum.reverse()
    end
  end

  defp camelize_keyword(val), do: val

  defp decap(str) do
    first = String.slice(str, 0..0) |> String.downcase()
    first <> String.slice(str, 1..-1)
  end
end
