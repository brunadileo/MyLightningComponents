public class BitlyIntegration {

	public String accessToken;

	public String getAccessToken() {
		HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Bitly/oauth/access_token');
        req.setMethod('POST');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();

	}

	public BitlyIntegration() {
        this.accessToken = getAccessToken();
    }

    public String shorten( String url ) {
    	System.debug(this.accessToken);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:Bitly/v3/shorten' +
            '?access_token=' + this.accessToken +
            '&longUrl=' + EncodingUtil.urlEncode( url, 'UTF-8' ) +
            '&format=txt'
        );
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('aqui: '+res.getBody());
        return res.getBody();
    }

    /*public static String getAuthorization(){
		HttpRequest req = new HttpRequest();
        req.setEndpoint('https://bitly.com/oauth/authorize?redirect_uri=https://bdileo-demo-developer-edition.na59.force.com/s/&client_id=e295142f41765755a6259fa60ab0bbfb8c3dfa37');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getStatus());
        return res.getBody();


    }*/

}