defmodule AddAttachmentsToSetTest do
  use ExUnit.Case

  test "multiple attachments" do
    file1 = "MyTest.txt"
    data1 = Base.encode64("This is MyTest.txt contents")
    file2 = "OtherFile.txt"
    data2 = Base.encode64("This is OtherFile.txt contents")

    op =
      ExAws.Support.add_attachments_to_set([
        [data: data1, file_name: file1],
        [data: data2, file_name: file2]
      ])

    assert op.data == %{
             "attachments" => [
               %{
                 "data" => data1,
                 "fileName" => file1
               },
               %{
                 "data" => data2,
                 "fileName" => file2
               }
             ]
           }

    assert op.headers == [
             {"x-amz-target", "AWSSupport_20130415.AddAttachmentsToSet"},
             {"content-type", "application/x-amz-json-1.1"}
           ]
  end
end
