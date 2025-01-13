module {
    public type HeaderField = (Text, Text);

    public type HttpRequest = {
        url : Text;
        method : Text;
        body : Blob;
        headers : [HeaderField];
    };

    public type HttpResponse = {
        status_code : Nat16;
        headers : [HeaderField];
        body : Blob;
    };
}