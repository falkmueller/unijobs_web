<%@include file="../private/crawler.jsp"%>
<%

Crawler c = new Crawler();
ParseData parseData;
HtmlParseData htmlParseData;

ParseData pJob;
HtmlParseData htmlParseDataJob;
String DataPath = getServletContext().getRealPath("/") + "data/";
String Uni;

String[][] Unis = {
                {"Cemnitz","https://www.tu-chemnitz.de/tu/stellen.php", "https://www.tu-chemnitz.de/verwaltung/personal/stellen", "true"},
                {"Jena","https://www.uni-jena.de/Stellenmarkt.html", "https://www.uni-jena.de/Universit%C3%A4t/Stellenmarkt/", "true"},
                {"Leipzig", "http://www.zv.uni-leipzig.de/universitaet/stellen-und-ausbildung/stellenausschreibungen/nichtwissenschaftliches-personal.html", "", "false"},
                {"Leipzig", "http://www.zv.uni-leipzig.de/universitaet/stellen-und-ausbildung/stellenausschreibungen/wissenschaftliches-personal.html", "", "false"}
            };


for(int i = 0; i < Unis.length; i++) { 
    out.println("<h2>" + Unis[i][0] + "</h2>");

    parseData = c.processUrl(Unis[i][1]);
    if (parseData != null){
        htmlParseData = (HtmlParseData) parseData;
        
        if (Unis[i][3] == "true"){
            Iterator<WebURL> iterator = htmlParseData.getOutgoingUrls().iterator();
            while(iterator.hasNext()) {
                WebURL setElement = iterator.next();
                if (setElement.getURL().startsWith(Unis[i][2])){
                        out.println(setElement + "<br/>");
                        pJob = c.processUrl(setElement.getURL());
                        if(pJob != null){
                            htmlParseDataJob = (HtmlParseData) pJob;

                            JSONObject pageData =new JSONObject();
                            pageData.put("Title",htmlParseDataJob.getTitle());
                            pageData.put("Content",htmlParseDataJob.getHtml());
                            pageData.put("Url",setElement.getURL());
                            pageData.put("Uni",Unis[i][0]);
                            pageData.put("Date",new Date());

                            String json = JSONValue.toJSONString(pageData);
                             try {
                                //write converted json data to a file named "file.json"
                                FileWriter writer = new FileWriter(DataPath + Unis[i][0] + "_" + setElement.getURL().replaceAll("[^\\w\\s]","") + ".json");
                                writer.write(json);
                                writer.close();

                            } catch (IOException e) {
                                out.println("File Error<br/>");
                                e.printStackTrace();
                            }
                        }
                    }
            }
        } else {

            out.println(Unis[i][1] + "<br/>");

            JSONObject pageData =new JSONObject();
            pageData.put("Title",htmlParseData.getTitle());
            pageData.put("Content",htmlParseData.getHtml());
            pageData.put("Url",Unis[i][1]);
            pageData.put("Uni",Unis[i][0]);
            pageData.put("Date",new Date());

            String json = JSONValue.toJSONString(pageData);
            try {
               //write converted json data to a file named "file.json"
               FileWriter writer = new FileWriter(DataPath + Unis[i][0] + "_" + Unis[i][1].replaceAll("[^\\w\\s]","") + ".json");
               writer.write(json);
               writer.close();

           } catch (IOException e) {
               out.println("File Error<br/>");
               e.printStackTrace();
           }

        }
        

    }
}
%>