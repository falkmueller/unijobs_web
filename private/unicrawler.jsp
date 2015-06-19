<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray, java.text.SimpleDateFormat" 
%><%@include file="crawler.jsp"%><%

class unicrawler {

    private String dataPath;
    private Crawler crawler;

    public unicrawler(){
        this.dataPath = getServletContext().getRealPath("/") + "data/";
        this.crawler = new Crawler();
    }

    public int CrawlSubPages(String Uni, String url, String subUrlPrefix){
        int CountPages = 0;

        ParseData parseData;
        HtmlParseData htmlParseData;

        parseData = this.crawler.processUrl(url);
        if (parseData != null){
            htmlParseData = (HtmlParseData) parseData;

            Iterator<WebURL> iterator = htmlParseData.getOutgoingUrls().iterator();
            while(iterator.hasNext()) {
                WebURL setElement = iterator.next();
                if (setElement.getURL().startsWith(subUrlPrefix)){
                    if (this.CrawlPage(Uni, setElement.getURL())){
                        CountPages++;
                    }
                }
            }
        }

        return CountPages;
    }

    public boolean CrawlPage(String Uni, String url){
        
        ParseData parseData;
        HtmlParseData htmlParseData;

        parseData = this.crawler.processUrl(url);
        if (parseData != null){
            htmlParseData = (HtmlParseData) parseData;
                
            JSONObject pageData =new JSONObject();
            pageData.put("Title",htmlParseData.getTitle());
            pageData.put("Content",htmlParseData.getHtml());
            pageData.put("Url",url);
            pageData.put("Uni",Uni);
            //pageData.put("Date",new Date());
            pageData.put("Date",new SimpleDateFormat("yyyy-MM-dd").format(new Date())); //new SimpleDateFormat("yyyy-MM-dd").format(date);
            String json = JSONValue.toJSONString(pageData);
            try {
               //write converted json data to a file named "file.json"
               FileWriter writer = new FileWriter(this.dataPath + Uni.replace(",", "") + "_" + url.replaceAll("[^\\w\\s]","").replace(",", "_") + ".json");
               writer.write(json);
               writer.close();
               return true;

           } catch (IOException e) {
               e.printStackTrace();
           }
        }

        return false;
    }

}
%>