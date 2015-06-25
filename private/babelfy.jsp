<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher,
         java.util.Map, java.util.HashMap, java.util.Collection, java.util.Collections, java.util.Comparator, java.util.ArrayList" 
%><%



class babelfy{

    private String ApiKey;

    public babelfy(){
        settings Settings = new settings();
        this.ApiKey = Settings.babelfy_Api_Key;
    }

    public ArrayList<TagWord> GetTagList(String text){
        
        String sbody = text.replaceAll("<[^>]*>", "");
        
        HashMap<String, TagWord> ResultSet = new HashMap<String, TagWord>();

        /****************************************************
        * Add CONCEPTS
        ****************************************************/
        JSONArray ApiResult = this.GetResultFromBabelfy(sbody, "CONCEPTS");

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
                    v.isconcept = true;
                    v.Count = count;
                    v.babelres = (String)object2.get("babelSynsetID");
                    ResultSet.put(Word, v);
                }
            }
        }

        /****************************************************
        * Add NAMED_ENTITIES
        ****************************************************/
        ApiResult = this.GetResultFromBabelfy(sbody, "NAMED_ENTITIES");

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
                    v.isconcept = false;
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
                    return o2.Count - o1.Count;
                }
            });
            
        return col;
    }

    private JSONArray GetResultFromBabelfy(String text, String annType){
        
        try {
            text = URLEncoder.encode( text, "UTF-8" );
            URL url = new URL("https://babelfy.io/v1/disambiguate?text=" + text + "&lang=DE&annType=" + annType + "&match=EXACT_MATCHING&cands=TOP&key=" + this.ApiKey);
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