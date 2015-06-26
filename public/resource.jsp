<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher,
         java.util.Map, java.util.HashMap, java.util.Collection, java.util.Collections, java.util.Comparator, java.util.ArrayList" 
%><%@include file="../settings.jsp"%>

<html>
     <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title><%=request.getParameter("oid")%></title>

    <!-- Bootstrap -->
    <link href="../public/css/bootstrap.min.css" rel="stylesheet">
    <link href="../public/css/styles.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
    <body>
        <div class="container">
        <h1><%=request.getParameter("oid")%></h1>

        <%

            try{
                URL FusekiUpdateUrl = new URL(request.getScheme(), 
                request.getServerName(), 
                "/fuseki/ds/query");

                String SparQLQuery = "PREFIX dc: <http://tomcat.falk-m.de/unijobs/resource/> \n"
                                  + " PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#>\n"
                                  + " PREFIX dbres: <http://dbpedia.org/resource/>\n"
                                  + " PREFIX dbonto: <http://dbpedia.org/ontology/>\n"
                                  + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"
                                  + " select * "
                                  + "WHERE { FILTER (?job = dc:" + request.getParameter("oid") + ") "
                                  + "       ?job ?p ?o."
                                  + "       OPTIONAL { ?o onto:Word ?Key_w }"
                                  + "       OPTIONAL { ?o onto:babelres ?Key_r }"
                                  + " }";

                String body = "query=" + URLEncoder.encode( SparQLQuery, "UTF-8" );

                HttpURLConnection connection = (HttpURLConnection) FusekiUpdateUrl.openConnection();
                connection.setRequestMethod( "GET" );
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

                String jsonString = "";
                for ( String line; (line = reader.readLine()) != null; )
                {
                  jsonString += line;
                }

                writer.close();
                reader.close();
                
                Object obj=JSONValue.parse(jsonString);
                
                JSONObject JobObj = (JSONObject)obj;
                JSONArray predicates = (JSONArray)((JSONObject)JobObj.get("results")).get("bindings");

                for(Object object: predicates){
                    JSONObject object2 =(JSONObject)object;
                    %>
                    <div class="panel panel-default">
                        <div class="panel-heading"><%= ((JSONObject)object2.get("p")).get("value") %></div>
                        <div class="panel-body">
                          <% 
  if(((JSONObject)object2.get("Key_w")) != null){
    out.println("<strong>" +  ((JSONObject)object2.get("Key_w")).get("value") + "</strong>");
    out.println(((JSONObject)object2.get("Key_r")).get("value"));
}else {
    out.println(((JSONObject)object2.get("o")).get("value")); 
}                        
%>
                        </div>
                      </div>
                    <%
                    
                }


            } catch (Exception e){
                out.println(e.toString());
            }
        %>
        </div>
    </body>
</html>


