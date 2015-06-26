<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher,
         java.util.Map, java.util.HashMap, java.util.Collection, java.util.Collections, java.util.Comparator, java.util.ArrayList,
         org.apache.http.HttpResponse, org.apache.http.client.HttpClient, org.apache.http.impl.client.DefaultHttpClient, org.apache.http.client.methods.HttpPost
         ,java.util.List, org.apache.http.NameValuePair, org.apache.http.client.entity.UrlEncodedFormEntity, org.apache.http.message.BasicNameValuePair,
         java.io.BufferedReader, java.io.InputStreamReader" 
%><%@include file="../settings.jsp"%>

<html>
     <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Resource: <%=request.getParameter("oid")%></title>

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

            try{
                String url = request.getScheme() + "://" + request.getServerName() + "/fuseki/ds/query";
                HttpClient client = new DefaultHttpClient();
		HttpPost post = new HttpPost(url);

      
                List<NameValuePair> urlParameters = new ArrayList<NameValuePair>();
		urlParameters.add(new BasicNameValuePair("query", SparQLQuery));
		post.setEntity(new UrlEncodedFormEntity(urlParameters));

                post.setHeader("Accept", "application/sparql-results+json");
                post.setHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");      
                
                HttpResponse resp = client.execute(post);

                BufferedReader rd = new BufferedReader(
                        new InputStreamReader(resp.getEntity().getContent()));
 
		String jsonString = "";
		String line = "";
		while ((line = rd.readLine()) != null) {
			jsonString += line;
		}
                
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


