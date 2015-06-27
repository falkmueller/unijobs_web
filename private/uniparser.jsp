<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher" 
%><%@include file="../private/babelfy.jsp"%><%

class uniparser {

    private String dataPath;
    private URL FusekiUpdateUrl; 
    private babelfy Babelfy;

    public uniparser(){
        this.dataPath = getServletContext().getRealPath("/") + "data/";
        try {        
            this.FusekiUpdateUrl = new URL(request.getScheme(), 
            request.getServerName(), 
            "/fuseki/ds/update");
        } catch (Exception e){}

        this.Babelfy = new babelfy();
    }

    public String parse(){
        String ReturnValue = "";

        File folder = new File(this.dataPath);
        File[] listOfFiles = folder.listFiles();
        
        int InsertMax = listOfFiles.length;
        if (InsertMax > 100){InsertMax = 100;}
        for (int i = 0; i < InsertMax; i++) {
          if (listOfFiles[i].isFile()) {
            String FileContent = "";

            try {
            FileContent = new String(Files.readAllBytes(Paths.get(this.dataPath + listOfFiles[i].getName())));
            Object obj=JSONValue.parse(FileContent);
            JSONObject obj2=(JSONObject)obj;

            ReturnValue += " ---- " + this.addJob(obj2);
            Files.delete(Paths.get(this.dataPath + listOfFiles[i].getName()));

            } catch (IOException e) {
                 ReturnValue += " IOException:" + listOfFiles[i].getName() + " " + e.toString();
               e.printStackTrace();
           } catch (Exception e){
                ReturnValue += e.toString();
            }
          } 
        }

        return ReturnValue + this.FusekiUpdateUrl;
    }

    private String BuildJobId(String Uni, String Url){
        try {
            MessageDigest m = MessageDigest.getInstance("MD5");
            m.reset();
            m.update(Url.getBytes());
            byte[] digest = m.digest();
            BigInteger bigInt = new BigInteger(1,digest);
            String hashtext = bigInt.toString(16);
            return Uni.replace(",", "") + "_" + hashtext;
         } catch (Exception e){
            return Uni.replace(",", "") + "_" + UUID.randomUUID().toString();
        }
    }

    private void addJob(String Uni, String Url, String Title, String Content, String salaryscale) throws MalformedURLException, UnsupportedEncodingException, IOException {

        settings Settings = new settings();
        String userPassword = Settings.Fuseki_User + ":" + Settings.Fuseki_Passwort;
        String JobId = this.BuildJobId(Uni, Url);
        
        String sContent = Content.replace("\n", "").replace("\r", "");
        sContent = sContent.replace("\"", "\\\"");
        Title = Title.replace("\"", "\\\"");

        String SparQLQuery = "PREFIX dc: <http://tomcat.falk-m.de/unijobs/resource/> \n"
                          + " PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#>\n"
                          + " PREFIX dbres: <http://dbpedia.org/resource/>\n"
                          + " PREFIX dbonto: <http://dbpedia.org/ontology/>\n"
                          + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"
                          + " DELETE {?s ?p ?o} \n"
                          + " WHERE  {FILTER (?s = dc:Job_" + JobId + ")} ;"
                          + " INSERT  DATA { dc:Job_" + JobId + " \n"    
				+ " rdf:type onto:job;\n"
                                + " onto:title \"" + Title + "\";\n"
                                + " onto:url \"" + Url + "\";\n"
                                + " onto:uid \"" + JobId + "\";\n"
                                + " onto:description \"" + sContent + "\";\n"
                                + " onto:in_uni <" + "http://dbpedia.org/resource/" + Uni + ">;\n"
                                + " onto:salaryscale \"" + salaryscale + "\";\n"
                                + "onto:ismanual false. \n"
                            + " }";

        String body = "update=" + URLEncoder.encode( SparQLQuery, "UTF-8" );

        HttpURLConnection connection = (HttpURLConnection) this.FusekiUpdateUrl.openConnection();
        connection.setRequestProperty("Authorization", "Basic " + new sun.misc.BASE64Encoder().encode(userPassword.getBytes()));
        connection.setRequestMethod( "POST" );
        connection.setDoInput( true );
        connection.setDoOutput( true );
        connection.setUseCaches( false );
        connection.setRequestProperty( "Content-Type",
                                       "application/x-www-form-urlencoded; charset=UTF-8" );
        connection.setRequestProperty( "Content-Length", String.valueOf(body.length()) );

        OutputStreamWriter writer = new OutputStreamWriter( connection.getOutputStream() );
        writer.write( body );
        writer.flush();

        BufferedReader reader = new BufferedReader(
                          new InputStreamReader(connection.getInputStream()) );

        //for ( String line; (line = reader.readLine()) != null; )
        //{
        //  ReturnValue += line;
        //}

        writer.close();
        reader.close();

        this.Babelfy.AddJobTags(JobId, Content);
    }

    private String addJob(JSONObject JobParseData) throws MalformedURLException, UnsupportedEncodingException, IOException{
        
        String Uni = (String)JobParseData.get("Uni");
        String JobTitle = (String)JobParseData.get("Title");
        String htmlContent = "";
        Document doc = Jsoup.parse((String)JobParseData.get("Content"));
        Elements JobContent;        

        if (Uni.equals("University_of_Jena")){
            JobContent = doc.select("#inhalt2");
        } else if (Uni.equals("Chemnitz_University_of_Technology")) {
             JobContent = doc.select(".page-content");
             JobTitle = JobContent.first().select("H4").first().text();
        } else if (Uni.equals("Hochschule_Mittweida")) {
             JobContent = doc.select(".news-single-item");
             JobTitle = doc.select("H1").first().text();
        } else if (Uni.equals("Bauhaus_University,_Weimar")) {
             JobContent = doc.select("#content_main");
        } else if (Uni.equals("Merseburg_University_of_Applied_Sciences")) {
             JobContent = doc.select(".news-single-item");
        } else if (Uni.equals("Hochschule_Harz")) {
             JobContent = doc.select(".tx-news-article");
        } else {
            JobContent = doc.select("body");
        }

        if (JobContent != null){
            htmlContent = JobContent.first().html();
        }

            this.addJob(Uni, (String)JobParseData.get("Url"), JobTitle, htmlContent, "" + ExtractSalaryscale(htmlContent));

        return "";
    }

    private int ExtractSalaryscale(String extText){
        int ReturnValue = 0;
        
        Pattern p = Pattern.compile("(Entgeltgruppe) (\\d+)|(\\d+) (TV-L)");
        Matcher m = p.matcher(extText);
        if (m.find()) {
            if (m.group(2) == null){
                ReturnValue = Integer.valueOf(m.group(3));
            } else {
                ReturnValue = Integer.valueOf(m.group(2));
            }
          
        } 

        return ReturnValue;
    }

}



%>