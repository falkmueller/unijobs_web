<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray" 
%><%@include file="../settings.jsp"
%><%@include file="../private/unicrawler.jsp"
%><%@include file="../private/uniparser.jsp"
%><%

class webservice {

    public String getResponse(){

       if (request.getParameter("function") == null){return "{\"message\":\"Parameter function fehlt \",\"success\":false}";}
       if (request.getParameter("function").toString().equals("crawl")){return JSONValue.toJSONString(this.crawl());}
       if (request.getParameter("function").toString().equals("parse")){return JSONValue.toJSONString(this.parse());}
       return "{\"message\":\"Webservicefunktion nicht vorhanden \",\"success\":false}";
    }

    private JSONObject crawl(){
        JSONObject responseData = new JSONObject();
        JSONArray ResponseArray = new JSONArray();
        
        settings Settings = new settings();
        if (request.getParameter("WsPw") == null || !request.getParameter("WsPw").toString().equals(Settings.Webservide_Passwort)){
            responseData.put("message","Das Passwort ist falsch");
            responseData.put("success", false);
            return responseData;
        }

        String[][] Unis = {
                {"Chemnitz_University_of_Technology","https://www.tu-chemnitz.de/tu/stellen.php", "https://www.tu-chemnitz.de/verwaltung/personal/stellen", "true"},
                {"University_of_Jena","https://www.uni-jena.de/Stellenmarkt.html", "https://www.uni-jena.de/Universit%C3%A4t/Stellenmarkt/", "true"},
                {"Hochschule_Mittweida", "https://www.hs-mittweida.de/newsampservice/stellenausschreibungen.html", "https://www.hs-mittweida.de/newsampservice/stellenausschreibungen/detail", "true"},
                {"Bauhaus_University,_Weimar", "http://www.uni-weimar.de/de/universitaet/aktuell/stellenausschreibungen/", "http://www.uni-weimar.de/de/universitaet/aktuell/stellenausschreibungen/", "true"},
                {"Merseburg_University_of_Applied_Sciences", "http://www.hs-merseburg.de/karriere/stellenausschreibungen/", "http://www.hs-merseburg.de/karriere/stellenausschreibungen/angebot/", "true"},
                {"Hochschule_Harz", "https://www.hs-harz.de/stellenausschreibungen/", "https://www.hs-harz.de/stellenausschreibungen/news/detail/", "true"}
            };

        unicrawler uniCrawler = new unicrawler();

        for(int i = 0; i < Unis.length; i++) { 
            JSONObject pageData =new JSONObject();
            pageData.put("uni",Unis[i][0]);
            pageData.put("url",Unis[i][1]);

            if (Unis[i][3] == "true"){
                pageData.put("count", uniCrawler.CrawlSubPages(Unis[i][0],Unis[i][1],Unis[i][2]));
            } else {
                uniCrawler.CrawlPage(Unis[i][0],Unis[i][1]);
                pageData.put("count", 1);
            } 
            ResponseArray.add(pageData);
        }
        
        responseData.put("data",ResponseArray);
        responseData.put("success", true);
        return responseData;
    }

    private JSONObject parse(){
        JSONObject responseData = new JSONObject();

        settings Settings = new settings();
        if (request.getParameter("WsPw") == null || !request.getParameter("WsPw").toString().equals(Settings.Webservide_Passwort)){
            responseData.put("message","Das Passwort ist falsch");
            responseData.put("success", false);
            return responseData;
        }

        uniparser UniParser = new uniparser();
        responseData.put("message", UniParser.parse());

        responseData.put("success", true);
        return responseData;
    }
}

webservice w = new webservice();
out.print(w.getResponse());


%>