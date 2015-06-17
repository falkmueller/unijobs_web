<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray" 
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

        if (request.getParameter("WsPw") == null || !request.getParameter("WsPw").toString().equals("test")){
            responseData.put("message","Das Passwort ist falsch");
            responseData.put("success", false);
            return responseData;
        }

        String[][] Unis = {
                {"Chemnitz_University_of_Technology","https://www.tu-chemnitz.de/tu/stellen.php", "https://www.tu-chemnitz.de/verwaltung/personal/stellen", "true"},
                {"University_of_Jena","https://www.uni-jena.de/Stellenmarkt.html", "https://www.uni-jena.de/Universit%C3%A4t/Stellenmarkt/", "true"},
                {"Leipzig_University", "http://www.zv.uni-leipzig.de/universitaet/stellen-und-ausbildung/stellenausschreibungen/nichtwissenschaftliches-personal.html", "", "false"},
                {"Leipzig_University", "http://www.zv.uni-leipzig.de/universitaet/stellen-und-ausbildung/stellenausschreibungen/wissenschaftliches-personal.html", "", "false"}
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
        if (request.getParameter("WsPw") == null || !request.getParameter("WsPw").toString().equals("test")){
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