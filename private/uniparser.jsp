<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID" 
%><%

class uniparser {

    private String dataPath;
    private URL FusekiUpdateUrl; 

    public uniparser(){
        this.dataPath = getServletContext().getRealPath("/") + "data/";
        try {        
            this.FusekiUpdateUrl = new URL(request.getScheme(), 
            request.getServerName(), 
            request.getServerPort(), 
            "/fuseki/ds/update");
        } catch (Exception e){}
    }

    public String parse(){
        String ReturnValue = "";

        File folder = new File(this.dataPath);
        File[] listOfFiles = folder.listFiles();

        for (int i = 0; i < 10; i++) {//listOfFiles.length
          if (listOfFiles[i].isFile()) {
            String FileContent = "";

            try {
            FileContent = new String(Files.readAllBytes(Paths.get(this.dataPath + listOfFiles[i].getName())));
            Object obj=JSONValue.parse(FileContent);
            JSONObject obj2=(JSONObject)obj;

            ReturnValue += " ---- " + this.addJob(obj2);
            
            } catch (IOException e) {
                 ReturnValue += " IOException:" + e.getMessage();
               e.printStackTrace();
           } catch (Exception e){
                ReturnValue += " FEHLER";
            }
          } 
        }

        return ReturnValue;
    }

    private String BuildJobId(String Uni, String Url){
        try {
            MessageDigest m = MessageDigest.getInstance("MD5");
            m.reset();
            m.update(Url.getBytes());
            byte[] digest = m.digest();
            BigInteger bigInt = new BigInteger(1,digest);
            String hashtext = bigInt.toString(16);
            return Uni + "_" + hashtext;
         } catch (Exception e){
            return Uni + "_" + UUID.randomUUID().toString();
        }
    }

    private String addJob(JSONObject JobParseData) throws MalformedURLException, UnsupportedEncodingException, IOException{
        String userPassword = "test" + ":" + "test";
        String JobId = this.BuildJobId((String)JobParseData.get("Uni"), (String)JobParseData.get("Url"));

        String SparQLQuery = "PREFIX dc: <http://tomcat.falk-m.de/> \n"
                          + " PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#>\n"
                          + " PREFIX dbres: <http://dbpedia.org/resource/>\n"
                          + " PREFIX dbonto: <http://dbpedia.org/ontology/>\n"
                          + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"
                          + " DELETE {?s ?p ?o} \n"
                          + " WHERE  {FILTER (?s = dc:Job_" + JobId + ")} ;"
                          + " INSERT  DATA { dc:Job_" + JobId + " \n"    
				+ " rdf:type onto:job;\n"
                                + " onto:title \"" + JobParseData.get("Title") + "\";\n"
                                + " onto:url \"" + JobParseData.get("Url") + "\";\n"
                                + " onto:uid \"" + JobId + "\";\n"
                                + " onto:description \"" + "Job.Description" + "\";\n"
                                + " onto:in_uni <" + "http://dbpedia.org/resource/" + JobParseData.get("Uni") + ">;\n"
                                + " onto:faculty \"" + "Job.faculty" + "\";\n"
                                + " onto:salaryscale \"" + "Job.salaryscale" + "\";\n"
                                + "onto:ismanual false. \n"
                            + " }";

        String ReturnValue = "";
    
        String body = "update=" + URLEncoder.encode( SparQLQuery, "UTF-8" );

        HttpURLConnection connection = (HttpURLConnection) this.FusekiUpdateUrl.openConnection();
        connection.setRequestProperty("Authorization", "Basic " + new sun.misc.BASE64Encoder().encode(userPassword.getBytes()));
        connection.setRequestMethod( "POST" );
        connection.setDoInput( true );
        connection.setDoOutput( true );
        connection.setUseCaches( false );
        connection.setRequestProperty( "Content-Type",
                                       "application/x-www-form-urlencoded" );
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

        return ReturnValue;
    }

}
%>