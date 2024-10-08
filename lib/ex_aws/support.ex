defmodule ExAws.Support do
  @moduledoc """
  Operations for AWS Support API

  The documentation and types provided lean heavily on the [AWS documentation for
  AWS Support](https://docs.aws.amazon.com/awssupport/latest/APIReference/API_Operations.html).
  The AWS documentation is the definitive source of information and should be consulted to
  understand how to use AWS Support and its API functions. The documentation on types and
  functions in the library may be helpful but it is merely helpful. It does not attempt to
  provide an explanation for how to use AWS Support.

  The library does not try to provide protection against invalid values, length restriction
  violations, or violations of pattern matching defined in the API documentation. There is some
  minimal checking for correct types but, generally, the data passed by the app is converted to
  a JSON representation and the error will be returned by the API when it is called.

  Generally the functions take required parameters separately from any optional arguments. The
  optional arguments are passed as a Map (with a defined type).

  The defined types used to pass optional arguments use the standard Elixir snake-case for keys. The
  API itself uses camel-case Strings for keys. The library provides the conversion. Most of the API
  keys use a lower-case letter for the first word and upper-case for the subsequent words. If there
  are exceptions to this rule they are handled by the library so an Elixir developer can just use
  standard snake-case for all the keys.

  ## Types of Operations

  The API provides two different groups of operations:

  - Support case management operations to manage the entire life cycle of your AWS support cases, from creating a case to resolving it
  - AWS Trusted Advisor operations to access AWS Trusted Advisor checks

  ### Support Case Management

  Support Case Management API's provide the following:

  - Open a support case
  - Get a list and detailed information about recent support cases
  - Filter your search for support cases by dates and case identifiers, including resolved cases
  - Add communications and file attachments to your cases, and add the email recipients for case
    correspondences. You can attach up to three files. Each file can be up to 5 MB
  - Resolve your cases

  ### AWS Trusted Advisor

  AWS Trusted Advisor API's provide the following:

  - Get the names and identifiers for the Trusted Advisor checks
  - Request that a Trusted Advisor check be run against your AWS account and resources
  - Get summaries and detailed information for your Trusted Advisor check results
  - Refresh your Trusted Advisor checks
  - Get the status of each Trusted Advisor check

  ## Endpoints

  AWS Support is a global service. This means that any endpoint that you use will update your
  support cases in the Support Center Console.

  For example, if you use the US East (N. Virginia) endpoint to create a case, you can use the US
  West (Oregon) or Europe (Ireland) endpoint to add a correspondence to the same case.

  You can use the following endpoints for the AWS Support API:

  - US East (N. Virginia) – https://support.us-east-1.amazonaws.com
  - US West (Oregon) – https://support.us-west-2.amazonaws.com
  - Europe (Ireland) – https://support.eu-west-1.amazonaws.com

  If you call the CreateCase operation to create test support cases, then AWS recommends that you
  include a subject line, such as TEST CASE-Please ignore. After you're done with your test support
  case, call the `resolve_case/1` operation to resolve it.

  To call the AWS Trusted Advisor operations in the AWS Support API, you must use the US East (N.
  Virginia) endpoint. Currently, the US West (Oregon) and Europe (Ireland) endpoints don't support
  the Trusted Advisor operations.

  ## Notes

  There is a lack of clarity in the doc on the format for `after_time` and `before_time`. Most
  likely an ISO8601 String works. I've seen random examples on the web using the YYYY-MM-DDTHH:MM
  format (for example, "2024-07-19T16:40").

  You must have a Business, Enterprise On-Ramp, or Enterprise Support plan to use the AWS Support
  API.

  If you call the AWS Support API from an account that doesn't have a Business, Enterprise On-Ramp,
  or Enterprise Support plan, the SubscriptionRequiredException error message appears. For
  information about changing your support plan, see [AWS
  Support](http://aws.amazon.com/premiumsupport/).
  """

  alias ExAws.Operation.JSON, as: ExAwsOperationJSON
  alias ExAws.Support.Utils

  # version of the AWS API
  @version "20130415"
  @namespace "AWSSupport"

  @typedoc """
  The support case ID

  ## Notes

  The case ID is an alphanumeric string in the following format: case-12345678910-2013-c4c1d2bf33c5cf47
  """
  @type case_id() :: binary()

  @typedoc """
  The unique identifier for the Trusted Advisor check
  """
  @type check_id() :: binary()

  @typedoc """
  The ID of the attachment set

  ## Notes

  If an attachment_set_id is not specified, a new attachment set is created, and the ID of the set is
  returned in the response. If an attachment_set_id is specified, the attachments are added to the
  specified set, if it exists.
  """
  @type attachment_set_id() :: binary()

  @typedoc """
  Attachment IDs are generated by the case management system when you
  add an attachment to a case or case communication

  Attachment IDs are returned in the AttachmentDetails objects that are returned by the
  `describe_communications/2` operation
  """
  @type attachment_id() :: binary()

  @typedoc """
  The body of an email communication to add to the support case.

  - Length Constraints: Minimum length of 1. Maximum length of 8000.
  """
  @type communication_body() :: binary()

  @typedoc """
  The email addresses in the CC line of an email to be added to the support case.

  - Minimum number of 0 items. Maximum number of 10 items.
  """
  @type cc_email_addresses() :: [binary()]

  @typedoc """
  The title of the support case

  The title appears in the Subject field on the AWS Support Center [Create
  Case](https://console.aws.amazon.com/support/home#/case/create) page.
  """
  @type subject() :: binary()

  @typedoc """
  An attachment to a case communication

  The attachment consists of the file name and the content of the file. Each attachment file size
  should not exceed 5 MB. File types that are supported include the following:
  pdf, jpeg, doc, log, text

  - data - attachment file contents, base64 encoded binary data object (see `Base.encode64/1`).
  - file_name - attachment filename
  """
  @type attachment() ::
          [{:data, binary()}, {:file_name, binary()}]
          | %{required(:data) => binary(), required(:file_name) => binary()}

  @typedoc """
  List of `t:attachment/0`
  """
  @type attachments() :: [attachment()]

  @typedoc """
  The category of problem for the support case

  ## Notes

  You can use the `describe_services/2` operation to get the category code for a service. Each AWS
  service defines its own set of category codes.
  """
  @type category_code() :: binary()

  @typedoc """
  The type of issue for the case

  ## Notes

  If you don't specify a value, the default is "technical".

  ## Valid Values
  ```
  ["customer-service", "technical"]
  ```
  """
  @type issue_type() :: binary()

  @typedoc """
  The language in which AWS Support handles the case

  ## Notes

  AWS Support currently supports Chinese (“zh”), English ("en"), Japanese ("ja") and Korean (“ko”).
  You must specify the ISO 639-1 code for the language parameter if you want support in that
  language.
  """
  @type language() :: binary()

  @typedoc """
  The code for the AWS service

  ## Notes

  You can use the `describe_services/2` function to get the possible service_code values.
  """
  @type service_code() :: binary()

  @typedoc """
  The start date for a filtered date search on support case communications

  ## Notes

  Case communications are available for 12 months after creation. String format is not well defined
  in the AWS doc. However, the format YYYY-MM-DDTHH:MM (for example: "2018-12-19T16:40") seems to
  appear in some examples.
  """
  @type after_time() :: binary()

  @typedoc """
  The ID displayed for a case in the AWS Support Center user interface
  """
  @type display_id() :: binary()

  @typedoc """
  The end date for a filtered date search on support case communications

  ## Notes

  Case communications are available for 12 months after creation. String format is not well defined
  in the AWS doc. However, the format YYYY-MM-DDTHH:MM (for example: "2018-12-19T16:40") seems to
  appear in some examples.
  """
  @type before_time() :: binary()

  @typedoc """
  The maximum number of results to return before paginating

  - Valid Range: Minimum value of 10. Maximum value of 100.
  """
  @type max_results() :: pos_integer()

  @typedoc """
  A resumption point for pagination

  Returned by previous call as "nextToken" in the JSON.
  """
  @type next_token() :: binary()

  @typedoc """
  A value that indicates the urgency of the case

  ## Notes

  This value determines the response time according to your service level agreement with AWS
  Support. You can use the `describe_severity_levels/1` operation to get the possible values for
  severity_code.

  For more information, see
  [SeverityLevel](https://docs.aws.amazon.com/awssupport/latest/APIReference/API_SeverityLevel.html)
  and [Choosing a
  Severity](https://docs.aws.amazon.com/awssupport/latest/user/getting-started.html#choosing-severity)
  in the AWS Support User Guide.

  Note: The availability of severity levels depends on the support plan for the AWS account.
  """
  @type severity_code() :: binary()

  @typedoc """
  Optional input for function `create_case/4`

  - `attachment_set_id` - The ID of a set of attachments that has been created by
  using `add_attachments_to_set/2`
  - `category_code` - The category for the service defined for the `service_code`
  value. You also get the category code for a service by calling `describe_services/2`.
  Each AWS service defines its own set of category codes.
  - `cc_email_addresses` - The AWS Support Center CC field on the Create Case
  page. You can list email addresses to be copied on any correspondence about the
  case. The account that opens the case is already identified by passing the
  AWS Credentials in the HTTP POST method or in a method or function call from
  one of the programming languages supported by an AWS SDK.
  - `issue_type` - The type of issue for the case. You can specify either
  "customer-service" or "technical." If you do not indicate a value, the
  default is "technical." Note: Service limit increases are not supported
  by the Support API; you must submit service limit increase requests in
  Support Center.
  - `language` - The human language in which AWS Support handles the case.
  English and Japanese are currently supported.
  - `service_code` - The code for an AWS service. You can get the possible values by calling
  `describe_services/2`.
  - `severity_code` - A value that indicates the urgency of the case, which in turn determines the
  response time according to your service level agreement with AWS Support. You can get the possible
  severity code values by calling `describe_severity_levels/1`. For more information about the
  meaning of the codes, see
  [SeverityLevel](https://docs.aws.amazon.com/awssupport/latest/APIReference/API_SeverityLevel.html)
  and [Choosing a
  Severity](https://docs.aws.amazon.com/awssupport/latest/user/getting-started.html#choosing-severity)
  in the _AWS Support User Guide_.
  """
  @type create_case_optional() ::
          [
            {:attachment_set_id, attachment_set_id()},
            {:category_code, category_code()},
            {:cc_email_addresses, cc_email_addresses()},
            {:issue_type, issue_type()},
            {:language, language()},
            {:service_code, service_code()},
            {:severity_code, severity_code()}
          ]
          | %{
              optional(:attachment_set_id) => attachment_set_id(),
              optional(:category_code) => category_code(),
              optional(:cc_email_addresses) => cc_email_addresses(),
              optional(:issue_type) => issue_type(),
              optional(:language) => language(),
              optional(:service_code) => service_code(),
              optional(:severity_code) => severity_code()
            }

  @typedoc """
  Optional input to the function `describe_cases/1`

  - after_time - The start date for a filtered date search on support case communications
  - before_time - The end date for a filtered date search on support case communications
  - case_id_list - A list of ID numbers of the support cases you want returned. The maximum number
  of cases is 100. Note: A case_id in AWS is not the value that you see in AWS Support web pages.
  That is the display_id. Its a unique identifier returned when you create a case that includes your
  account id. The case ID is an alphanumeric string formatted as shown in this example:
  "case-12345678910-2013-c4c1d2bf33c5cf47"
  - display_id - This is the 10 digit number shown in the AWS Support web interface and labeled
  "Case Id"
  - include_resolved_cases - Specifies whether resolved support cases should be included in the
  `describe_cases/1` results. The default is false. If you are not getting data back and you expect
  to, ensure that you are setting this to true.
  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".
  - max_results: The maximum number of results to return before paginating
  - next_token: A resumption point for pagination
  """
  @type describe_cases_optional() ::
          [
            {:after_time, after_time()},
            {:before_time, before_time()},
            {:case_id_list, [case_id()]},
            {:display_id, display_id()},
            {:include_communications, boolean()},
            {:include_resolved_cases, boolean()},
            {:language, language()},
            {:max_results, max_results()},
            {:next_token, next_token()}
          ]
          | %{
              optional(:after_time) => after_time(),
              optional(:before_time) => before_time(),
              optional(:case_id_list) => [case_id()],
              optional(:display_id) => display_id(),
              optional(:include_communications) => boolean(),
              optional(:include_resolved_cases) => boolean(),
              optional(:language) => language(),
              optional(:max_results) => max_results(),
              optional(:next_token) => next_token()
            }

  @typedoc """
  Optional input to the `describe_communications/2` function

  - after_time - The start date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation. String format is:
  YYYY-MM-DDTHH:MM, for example: 2018-12-19T16:40"
  - before_time - The end date for a filtered date search on support case communications.
  Case communications are available for 12 months after creation.
  - max_results - The maximum number of results to return before paginating. Integer.
  Valid Range: Minimum value of 10. Maximum value of 100.
  - next_token - A resumption point for pagination
  """
  @type describe_communications_optional() ::
          [
            {:after_time, after_time()},
            {:before_time, before_time()},
            {:max_results, max_results()},
            {:next_token, next_token()}
          ]
          | %{
              optional(:after_time) => after_time(),
              optional(:before_time) => before_time(),
              optional(:max_results) => max_results(),
              optional(:next_token) => next_token()
            }

  @doc """
  Adds one or more attachments to an attachment set

  ## Parameter Descriptions

  * attachments - One or more attachments to add to the set
  * attachment_set_id - The ID of the attachment set (to add the attachments to). If nil is provided
    for this then a new attachment set is created

  ## Notes

  If an attachment_set_id is not specified, a new attachment set is created, and the ID of the set
  is returned in the response. If an attachment_set_id is specified, the attachments are added to
  the specified set, if it exists.

  An attachment set is a temporary container for attachments that are to be added to a case or case
  communication. The set is available for one hour after it is created; the expiryTime returned in
  the response indicates when the set expires. The maximum number of attachments in a set is 3, and
  the maximum size of any attachment in the set is 5 MB.

  ## Examples

      iex> attachment_set_id = "as-2f5a6faa2a4a1e600-mu-nk5xQlBr70-G1cUos5LZkd38KOAHZa9BMDVzNEXAMPLE"
      iex> data = Base.encode64("This is a test")
      iex> attachments = [%{file_name: "troubleshoot-screenshot.png", data: data}]
      iex> ExAws.Support.add_attachments_to_set(attachments, attachment_set_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "attachmentSetId" => "as-2f5a6faa2a4a1e600-mu-nk5xQlBr70-G1cUos5LZkd38KOAHZa9BMDVzNEXAMPLE",
          "attachments" => [
            %{
              "data" => "VGhpcyBpcyBhIHRlc3Q=",
              "fileName" => "troubleshoot-screenshot.png"
            }
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.AddAttachmentsToSet"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }

      iex> file1 = "MyTest.txt"
      iex> data1 = Base.encode64("This is MyTest.txt contents")
      iex> file2 = "OtherFile.txt"
      iex> data2 = Base.encode64("This is OtherFile.txt contents")
      iex> attachments = [[data: data1, file_name: file1], [data: data2, file_name: file2]]
      iex> ExAws.Support.add_attachments_to_set(attachments)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "attachments" => [
            %{
              "data" => "VGhpcyBpcyBNeVRlc3QudHh0IGNvbnRlbnRz",
              "fileName" => "MyTest.txt"
            },
            %{
              "data" => "VGhpcyBpcyBPdGhlckZpbGUudHh0IGNvbnRlbnRz",
              "fileName" => "OtherFile.txt"
            }
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.AddAttachmentsToSet"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec add_attachments_to_set(attachments(), attachment_set_id() | nil) :: ExAws.Operation.JSON.t()
  def add_attachments_to_set(attachments, attachment_set_id \\ nil) when is_list(attachments) do
    case attachment_set_id do
      nil -> %{}
      val -> %{attachment_set_id: val}
    end
    |> Map.merge(%{attachments: keyword_to_map(attachments)})
    |> Utils.camelize_map()
    |> request(:add_attachments_to_set)
  end

  @doc """
  Adds additional customer communication to an AWS Support case

  ## Parameter Descriptions

    * case_id - The AWS Support case ID requested or returned in the call
    * attachment_set_id - The ID of a set of one or more attachments for
    the communication to add to the case
    * communication_body - The body of an email communication to add to the
    support case
    * cc_email_addresses - The email addresses in the CC line of an email to be
    added to the support case

  ## Notes

  You use the case_id value to identify the case to add communication to. You can list a set of
  email addresses to copy on the communication using the cc_email_addresses value. The
  communication_body value contains the text of the communication.

  The response indicates the success or failure of the request

  ## Examples

      iex> case_id = "case-12345678910-2013-c4c1d2bf33c5cf47"
      iex> attachment_set_id = "attachment_set_id"
      iex> communication_body = "Important text"
      iex> cc_email_addresses = ["test@test.com", "xyz@test.com"]
      iex> ExAws.Support.add_communication_to_case(case_id, attachment_set_id, communication_body, cc_email_addresses)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "attachmentSetId" => "attachment_set_id",
          "caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47",
          "ccEmailAddresses" => ["test@test.com", "xyz@test.com"],
          "communicationBody" => "Important text"
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.AddCommunicationToCase"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec add_communication_to_case(case_id(), attachment_set_id(), communication_body(), cc_email_addresses()) ::
          ExAws.Operation.JSON.t()
  def add_communication_to_case(case_id, attachment_set_id, communication_body, cc_email_addresses \\ []) do
    %{
      case_id: case_id,
      attachment_set_id: attachment_set_id,
      communication_body: communication_body,
      cc_email_addresses: cc_email_addresses
    }
    |> Utils.camelize_map()
    |> request(:add_communication_to_case)
  end

  @doc """
  Creates a new case in the AWS Support Center

  ## Parameter Descriptions

  * subject - The title of the support case
  * communication_body - The communication body text that describes the issue
  * create_case_optional - Optional data used when creating the case

  ## Notes

  This operation is modeled on the behavior of the AWS Support Center Create Case page

  * subject - The Subject field on the AWS Support Center Create Case page.
  * communication_body - The Description field on the AWS Support Center Create Case page.
  * create_case_optional - Optional fields

  Note: To add additional communication or attachments to an existing case, use
  `add_communication_to_case/4`.

  A successful `create_case/3` request returns an AWS Support case number. Case numbers are used by
  the describe_cases operation to retrieve existing AWS Support cases.

  ## Examples

      iex> subject = "Question about my account"
      iex> communication_body = "I want to learn more about the AWS XYZZY service."
      iex> ExAws.Support.create_case(subject, communication_body)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "communicationBody" => "I want to learn more about the AWS XYZZY service.",
          "subject" => "Question about my account"
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.CreateCase"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }

      iex> create_case_optional = [
      ...>      service_code: "amazon-relational-database-service-mariadb",
      ...>      severity_code: "urgent",
      ...>      issue_type: "technical",
      ...>      category_code: "connectivity",
      ...>      language: "en"
      ...> ]
      iex> subject = "Problem with our MariaDB"
      iex> communication_body = "Cannot connect to XYZ"
      iex> ExAws.Support.create_case(subject, communication_body, create_case_optional)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "categoryCode" => "connectivity",
          "communicationBody" => "Cannot connect to XYZ",
          "issueType" => "technical",
          "language" => "en",
          "serviceCode" => "amazon-relational-database-service-mariadb",
          "severityCode" => "urgent",
          "subject" => "Problem with our MariaDB"
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.CreateCase"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec create_case(subject(), communication_body(), create_case_optional()) :: ExAws.Operation.JSON.t()
  def create_case(subject, communication_body, create_case_optional \\ [])
      when is_binary(subject) and is_binary(communication_body) do
    create_case_optional
    |> keyword_to_map()
    |> Map.merge(%{subject: subject, communication_body: communication_body})
    |> Utils.camelize_map()
    |> request(:create_case)
  end

  @doc """
  Returns the attachment that has the specified ID

  ## Parameter Descriptions

  * attachment_id - The ID of the attachment to return

  ## Notes

  Attachments can include screenshots, error logs, or other files that describe your issue.
  Attachment IDs are generated by the case management system when you add an attachment to a case or
  case communication. Attachment IDs are returned in the AttachmentDetails objects that are returned
  by the `describe_communications/2` operation.

  ## Examples

      iex> attachment_id = "attachment-KBnjRNrePd9D6Jx0"
      iex> ExAws.Support.describe_attachment(attachment_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"attachmentId" => "attachment-KBnjRNrePd9D6Jx0"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeAttachment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_attachment(attachment_id()) :: ExAws.Operation.JSON.t()
  def describe_attachment(attachment_id) do
    %{attachment_id: attachment_id}
    |> Utils.camelize_map()
    |> request(:describe_attachment)
  end

  @doc """
  Returns a list of cases that you specify by passing one or more case IDs

  ## Parameter Descriptions

  * describe_cases_optional - Optional fields

  ## Notes

  Since no arguments are required you can call this API to list all your cases.

  In addition, you can filter the cases by date by setting values for the after_time and before_time
  request parameters. You can set values for the include_resolved_cases and include_communications
  request parameters to control how much information is returned.

  Case data is available for 12 months after creation. If a case was created more than 12 months
  ago, a request for data might cause an error.

  The response returns the following in JSON format:

  * One or more CaseDetails data types.
  * One or more next_token values, which specify where to paginate the returned records represented
  by the CaseDetails objects.

  ## Examples

      iex> ExAws.Support.describe_cases()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeCases"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }

      iex> ExAws.Support.describe_cases(after_time: "2018-12-01T01:00", include_resolved_cases: true)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"afterTime" => "2018-12-01T01:00", "includeResolvedCases" => true},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeCases"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_cases(describe_cases_optional()) :: ExAws.Operation.JSON.t()
  def describe_cases(describe_cases_optional \\ []) do
    describe_cases_optional
    |> keyword_to_map()
    |> Utils.camelize_map()
    |> request(:describe_cases)
  end

  @doc """
  Returns communications (and attachments) for one or more support cases

  ## Parameter Descriptions

  * case_id - The support case ID requested or returned in the call
  * describe_communications_optional - optional data

  ## Notes

  You can use the after_time and before_time parameters to filter by date. You can use the caseId
  parameter to restrict the results to a particular case.

  Case data is available for 12 months after creation. If a case was created more than 12 months
  ago, a request for data might cause an error.

  You can use the max_results and next_token parameters to control the pagination of the result set.
  Set max_results to the number of cases you want displayed on each page, and use next_token to
  specify the resumption of pagination.

  ## Examples

      iex> case_id = "case-12345678910-2013-c4c1d2bf33c5cf47"
      iex> ExAws.Support.describe_communications(case_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeCommunications"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }

      iex> describe_communication_optional = %{after_time: "2018-12-01T01:00", max_results: 10}
      iex> case_id = "case-12345678910-2013-c4c1d2bf33c5cf47"
      iex> ExAws.Support.describe_communications(case_id, describe_communication_optional)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "afterTime" => "2018-12-01T01:00",
          "caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47",
          "maxResults" => 10
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeCommunications"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_communications(case_id(), describe_communications_optional()) :: ExAws.Operation.JSON.t()
  def describe_communications(case_id, describe_communications_optional \\ []) do
    describe_communications_optional
    |> keyword_to_map()
    |> Map.merge(%{case_id: case_id})
    |> Utils.camelize_map()
    |> request(:describe_communications)
  end

  @doc """
  Returns a list of CreateCaseOption types along with the corresponding supported hours and language
  availability

  ## Parameter Descriptions

  * service_code - The code for the AWS service
  * category_code - The category of problem for the support case.
  * issue_type - The type of issue for the case
  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".

  ## Notes

  You can specify the language categoryCode, issueType and serviceCode used to retrieve the
  CreateCaseOptions.

  ## Examples

      iex> service_code = "rds"
      iex> issue_type = "technical"
      iex> category_code = "console"
      iex> ExAws.Support.describe_create_case_options(service_code, category_code, issue_type)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "categoryCode" => "console",
          "issueType" => "technical",
          "language" => "en",
          "serviceCode" => "rds"
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeCreateCaseOptions"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_create_case_options(service_code(), category_code(), issue_type(), language()) ::
          ExAws.Operation.JSON.t()
  def describe_create_case_options(service_code, category_code, issue_type, language \\ "en") do
    %{service_code: service_code, category_code: category_code, issue_type: issue_type, language: language}
    |> Utils.camelize_map()
    |> request(:describe_create_case_options)
  end

  @doc """
  Returns the current list of AWS services and a list of service categories that applies to each one

  ## Parameter Descriptions

  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".
  * service_code_list - list of service codes available for AWS services

  ## Notes

  You then use service names and categories in your create_case requests. Each AWS service has its
  own set of categories.

  The service codes and category codes correspond to the values that are displayed in the Service
  and Category drop-down lists on the AWS Support Center Create Case page. The values in those
  fields, however, do not necessarily match the service codes and categories returned by the
  `describe_services/2` request. Always use the service codes and categories obtained
  programmatically. This practice ensures that you always have the most recent set of service and
  category codes.

  ## Examples

      iex> ExAws.Support.describe_services()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"language" => "en", "serviceCodeList" => []},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeServices"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_services(language(), [binary()]) :: ExAws.Operation.JSON.t()
  def describe_services(language \\ "en", service_code_list \\ []) do
    %{language: language, service_code_list: service_code_list}
    |> Utils.camelize_map()
    |> request(:describe_services)
  end

  @doc """
  Returns the list of severity levels that you can assign to an AWS Support case

  ## Parameter Descriptions

  * language - The ISO 639-1 code for the language in which AWS provides support. Language
    parameters must be passed explicitly for operations that take them. The default is "en".

  ## Notes

  The severity level for a case is also a field in the CaseDetails data type
  included in any `create_case/1` request.

  ## Parameter Descriptions

  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".

  ## Examples

      iex> ExAws.Support.describe_severity_levels()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"language" => "en"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeSeverityLevels"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_severity_levels(language()) :: ExAws.Operation.JSON.t()
  def describe_severity_levels(language \\ "en") do
    %{language: language}
    |> Utils.camelize_map()
    |> request(:describe_severity_levels)
  end

  @doc """
  Returns a list of supported languages for a specified category_code, issue_type and service_code

  ## Parameter Descriptions

  * service_code - The code for the AWS service
  * category_code - The category of problem for the support case
  * issue_type - The type of issue for the case

  ## Notes

  The returned supported languages will include a ISO 639-1 code for the language, and the language display name.

  ## Examples

      iex> service_code = "rds"
      iex> category_code = "console"
      iex> issue_type = "technical"
      iex> ExAws.Support.describe_supported_languages(service_code, category_code, issue_type)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "categoryCode" => "console",
          "issueType" => "technical",
          "serviceCode" => "rds"
        },
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeSupportedLanguages"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_supported_languages(service_code(), category_code(), issue_type()) :: ExAws.Operation.JSON.t()
  def describe_supported_languages(service_code, category_code, issue_type) do
    %{service_code: service_code, category_code: category_code, issue_type: issue_type}
    |> Utils.camelize_map()
    |> request(:describe_supported_languages)
  end

  @doc """
  Returns the refresh status of the Trusted Advisor checks that have the
  specified check IDs

  ## Parameter Descriptions

  - check_ids - a list of `t:check_id/0` Strings

  ## Notes

  Check IDs can be obtained by calling `describe_trusted_advisor_checks/1`.

  Some checks are refreshed automatically, and their refresh statuses cannot be retrieved by using
  this operation. Use of the `describe_trusted_advisor_check_refresh_statuses/1` operation for these
  checks causes an InvalidParameterValue error.

  To call the AWS Trusted Advisor operations in the AWS Support API, you must use the US East (N.
  Virginia) endpoint. Currently, the US West (Oregon) and Europe (Ireland) endpoints don't support
  the Trusted Advisor operations. For more information, see About the AWS Support API in the AWS
  Support User Guide.

  ## Examples

      iex> check_ids = ["Pfx0RwqBli"]
      iex> ExAws.Support.describe_trusted_advisor_check_refresh_statuses(check_ids)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"checkIds" => ["Pfx0RwqBli"]},
        params: %{},
        headers: [
          {"x-amz-target",
          "AWSSupport_20130415.DescribeTrustedAdvisorCheckRefreshStatuses"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_trusted_advisor_check_refresh_statuses([check_id()]) :: ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_refresh_statuses(check_ids) do
    %{check_ids: check_ids}
    |> Utils.camelize_map()
    |> request(:describe_trusted_advisor_check_refresh_statuses)
  end

  @doc """
  Returns the results of the Trusted Advisor check that has the specified check ID

  ## Parameter Descriptions

  * check_id - The unique identifier for the Trusted Advisor check
  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".

  ## Notes

  Check IDs can be obtained by calling DescribeTrustedAdvisorChecks.

  The response contains a TrustedAdvisorCheckResult object, which contains these three objects:

    * TrustedAdvisorCategorySpecificSummary
    * TrustedAdvisorResourceDetail
    * TrustedAdvisorResourcesSummary

  In addition, the response contains these fields:

    * status. The alert status of the check: "ok" (green), "warning" (yellow), "error" (red), or
      "not_available".
    * timestamp. The time of the last refresh of the check.
    * checkId. The unique identifier for the check.

  ## Examples

      iex> check_id = "Pfx0RwqBli"
      iex> ExAws.Support.describe_trusted_advisor_check_result(check_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"checkId" => "Pfx0RwqBli", "language" => "en"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorCheckResult"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_trusted_advisor_check_result(check_id(), language()) :: ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_result(check_id, language \\ "en") do
    %{check_id: check_id, language: language}
    |> Utils.camelize_map()
    |> request(:describe_trusted_advisor_check_result)
  end

  @doc """
  Returns information about all available Trusted Advisor checks, including name, ID, category,
  description, and metadata

  ## Parameter Descriptions

  * language - The ISO 639-1 code for the language in which AWS provides support.
  Language parameters must be passed explicitly for operations that take them. The
  default is "en".

  ## Notes

  You must specify a language code; English ("en") and Japanese ("ja") are currently supported. The
  response contains a TrustedAdvisorCheckDescription for each check.

  The names and descriptions for Trusted Advisor checks are subject to change. We recommend that you
  specify the check ID in your code to uniquely identify a check.

  To call the AWS Trusted Advisor operations in the AWS Support API, you must use the US East (N.
  Virginia) endpoint. Currently, the US West (Oregon) and Europe (Ireland) endpoints don't support
  the Trusted Advisor operations. For more information, see [About the AWS Support
  API](https://docs.aws.amazon.com/awssupport/latest/user/about-support-api.html#endpoint) in the
  AWS Support User Guide.

  ## Examples

      iex> ExAws.Support.describe_trusted_advisor_checks()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"language" => "en"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorChecks"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_trusted_advisor_checks(language()) :: ExAws.Operation.JSON.t()
  def describe_trusted_advisor_checks(language \\ "en") do
    %{language: language}
    |> Utils.camelize_map()
    |> request(:describe_trusted_advisor_checks)
  end

  @doc """
  Returns the summaries of the results of the Trusted Advisor checks that have the specified check
  IDs

  ## Parameter Descriptions

  - check_ids - a list of `t:check_id/0` Strings

  ## Notes

  check_ids can be obtained by calling `describe_trusted_advisor_checks/1`.

  The response contains an array of TrustedAdvisorCheckSummary objects.

  The names and descriptions for Trusted Advisor checks are subject to change. We recommend that you
  specify the check ID in your code to uniquely identify a check.

  To call the AWS Trusted Advisor operations in the AWS Support API, you must use the US East (N.
  Virginia) endpoint. Currently, the US West (Oregon) and Europe (Ireland) endpoints don't support
  the Trusted Advisor operations. For more information, see [About the AWS Support
  API](https://docs.aws.amazon.com/awssupport/latest/user/about-support-api.html#endpoint) in the
  AWS Support User Guide.

  ## Examples

      iex> check_ids = ["Pfx0RwqBli", "Tzz9913B7d"]
      iex> ExAws.Support.describe_trusted_advisor_check_summaries(check_ids)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"checkIds" => ["Pfx0RwqBli", "Tzz9913B7d"]},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.DescribeTrustedAdvisorCheckSummaries"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec describe_trusted_advisor_check_summaries([check_id()]) :: ExAws.Operation.JSON.t()
  def describe_trusted_advisor_check_summaries(check_ids) do
    %{check_ids: check_ids}
    |> Utils.camelize_map()
    |> request(:describe_trusted_advisor_check_summaries)
  end

  @doc """
  Requests a refresh of the Trusted Advisor check that has the specified check_id

  ## Parameter Descriptions

  - check_id - The unique identifier for the Trusted Advisor check

  ## Notes

  Check IDs can be obtained by calling `describe_trusted_advisor_checks/1`

  Some checks are refreshed automatically, and they cannot be refreshed by using this operation. Use
  of the `refresh_trusted_advisor_check/1` function for these checks causes an InvalidParameterValue
  error.

  The names and descriptions for Trusted Advisor checks are subject to change. We recommend that you
  specify the check ID in your code to uniquely identify a check.

  To call the AWS Trusted Advisor operations in the AWS Support API, you must use the US East (N.
  Virginia) endpoint. Currently, the US West (Oregon) and Europe (Ireland) endpoints don't support
  the Trusted Advisor operations. For more information, see [About the AWS Support
  API](https://docs.aws.amazon.com/awssupport/latest/user/about-support-api.html#endpoint) in the
  AWS Support User Guide.

  ## Examples

      iex> check_id = "Pfx0RwqBli"
      iex> ExAws.Support.refresh_trusted_advisor_check(check_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"checkId" => "Pfx0RwqBli"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.RefreshTrustedAdvisorCheck"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec refresh_trusted_advisor_check(check_id()) :: ExAws.Operation.JSON.t()
  def refresh_trusted_advisor_check(check_id) do
    %{check_id: check_id}
    |> Utils.camelize_map()
    |> request(:refresh_trusted_advisor_check)
  end

  @doc """
  Takes a case_id and returns the initial state of the case along with the state of the case after
  the call to resolve_case completed

  ## Parameter Descriptions

  - case_id - The AWS Support case id that you are resolving

  ## Examples

      iex> case_id = "case-12345678910-2013-c4c1d2bf33c5cf47"
      iex> ExAws.Support.resolve_case(case_id)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"caseId" => "case-12345678910-2013-c4c1d2bf33c5cf47"},
        params: %{},
        headers: [
          {"x-amz-target", "AWSSupport_20130415.ResolveCase"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :support,
        before_request: nil
      }
  """
  @spec resolve_case(case_id()) :: ExAws.Operation.JSON.t()
  def resolve_case(case_id) do
    %{case_id: case_id}
    |> Utils.camelize_map()
    |> request(:resolve_case)
  end

  ####################
  # Helper Functions #
  ####################

  defp request(data, action) do
    operation = Utils.camelize(action, %{default: :upper, subkeys: %{}, keys: %{}})

    ExAwsOperationJSON.new(:support, %{
      data: data,
      headers: [
        {"x-amz-target", "#{@namespace}_#{@version}.#{operation}"},
        {"content-type", "application/x-amz-json-1.1"}
      ]
    })
  end

  defp keyword_to_map(data) when is_map(data), do: data
  defp keyword_to_map([]), do: %{}
  defp keyword_to_map(data) when is_list(data), do: Utils.keyword_to_map(data)
  defp keyword_to_map(_), do: %{}
end
