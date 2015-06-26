<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher,
         java.util.Map, java.util.HashMap, java.util.Collection, java.util.Collections, java.util.Comparator, java.util.ArrayList" 
%><%



class babelfy{

    private settings Settings;
    private URL FusekiUpdateUrl;

    public babelfy(){
        this.Settings = new settings();
        try {        
            this.FusekiUpdateUrl = new URL(request.getScheme(), 
            request.getServerName(), 
            "/fuseki/ds/update");
        } catch (Exception e){}
    }

    public void AddJobTags(String JobId, String text) throws MalformedURLException, UnsupportedEncodingException, IOException {
        ArrayList<TagWord> namedEntities = this.GetTagList(text, false);
        
        ArrayList<TagWord> concepts = this.GetTagList(text, true);
        if (concepts.size() > 10){
            concepts.subList(5, concepts.size()).clear();
        }
        
        ArrayList<babelfy.TagWord> al= new ArrayList<babelfy.TagWord>();
        al.addAll(namedEntities);
        al.addAll(concepts);

        if(al.size() == 0){return;}

        String SparQLQuery = "PREFIX dc: <http://tomcat.falk-m.de/unijobs/resource/> \n"
                          + " PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#>\n"
                          + " PREFIX dbres: <http://dbpedia.org/resource/>\n"
                          + " PREFIX dbonto: <http://dbpedia.org/ontology/>\n"
                          + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"
                          + " PREFIX bn: <http://babelnet.org/rdf/>\n";
        
        int kid = 0;

        for(TagWord o: al){

            String word = o.Word;
            word = word.replace("\n", "").replace("\r", "");
            word = word.replace("\"", "\\\"");

            kid = kid + 1;
            
            SparQLQuery += " INSERT  DATA { dc:Job_" + JobId + " onto:keywords _:" + kid + ". \n"
                          + "   _:" + kid + " onto:Word \"" + word + "\"; \n"
                          + "   onto:babelres " + o.babelres + "; \n"
                          + "   onto:url \"" + o.Url + "\"; \n"
                          + "   onto:isconcept " + (o.isconcept? "true" : "false") + ". \n"
                          + "};\n";
        }

        String userPassword = this.Settings.Fuseki_User + ":" + this.Settings.Fuseki_Passwort;
  
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
    }

    public ArrayList<TagWord> GetTagList(String text, boolean isconcept ){
        
        String sbody = text.replaceAll("<[^>]*>", "");
        
        HashMap<String, TagWord> ResultSet = new HashMap<String, TagWord>();

        /****************************************************
        * Add CONCEPTS
        ****************************************************/
        JSONArray ApiResult = this.GetResultFromBabelfy(sbody, (isconcept ? "CONCEPTS" : "NAMED_ENTITIES"));

        for(Object object: ApiResult){
            JSONObject object2 =(JSONObject)object;
            JSONObject charFragment=(JSONObject)object2.get("charFragment");

            String Word = sbody.substring(((Long)charFragment.get("start")).intValue(),((Long)charFragment.get("end")).intValue() + 1);

            if(Character.isUpperCase(Word.charAt(0))){

                if (!ResultSet.containsKey(Word)){
                    int count = sbody.split("(?i)" + Word, -1).length-1;

                    TagWord v = new TagWord();
                    v.Word = Word;
                    v.Url = (((String)object2.get("DBpediaURL")).equals("") ? (String)object2.get("BabelNetURL") : (String)object2.get("DBpediaURL") );
                    v.isconcept = isconcept;
                    v.Count = count;
                    v.babelres = (String)object2.get("babelSynsetID");
                    ResultSet.put(Word, v);
                }
            }
        }

        /****************************************************
        * Sort and Output
        ****************************************************/
        ArrayList<TagWord> col = new ArrayList<TagWord>(ResultSet.values());

        Collections.sort(col, new Comparator<TagWord>() {

                public int compare(TagWord o1, TagWord o2) {
                    return o1.Count - o2.Count;
                }
            });
            
        return col;
    }

    private JSONArray GetResultFromBabelfy(String text, String annType){
        
        try {
            text = URLEncoder.encode( text, "UTF-8" );
            URL url = new URL("https://babelfy.io/v1/disambiguate?text=" + text + "&lang=DE&annType=" + annType + "&match=EXACT_MATCHING&cands=TOP&key=" + this.Settings.babelfy_Api_Key);
            String ReturnValue = "";
            HttpURLConnection connection = (HttpURLConnection)url.openConnection();
            connection.setRequestMethod( "GET" );

            BufferedReader in = new BufferedReader(
                                    new InputStreamReader(
                                    connection.getInputStream()));
            String inputLine;

            while ((inputLine = in.readLine()) != null) 
                ReturnValue += inputLine;
            in.close();

            Object obj=JSONValue.parse(ReturnValue);

            return (JSONArray)obj;
        } catch (Exception e){
            return new JSONArray();
        }
    }

    class TagWord {

    public String Word;
    public String Url;
    public boolean isconcept;
    public int Count;
    public String babelres; 

    }

}


%>