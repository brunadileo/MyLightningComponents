public class BitlyIntegration {
	public String callout() {
		HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Bitly/oauth/access_token');
        req.setMethod('POST');
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();

	}

	public BitlyIntegration() {
        this.accessToken = getAccessToken();
    }
}