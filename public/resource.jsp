<%@ page import="org.json.simple.JSONValue, org.json.simple.JSONObject, org.json.simple.JSONArray,
         java.nio.file.Files, java.nio.file.Paths,
         java.net.*, java.io.*, java.security.*, java.math.BigInteger, java.util.UUID,
         org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements,
         java.util.regex.Pattern, java.util.regex.Matcher,
         java.util.Map, java.util.HashMap, java.util.Collection, java.util.Collections, java.util.Comparator, java.util.ArrayList" 
%><%@include file="../settings.jsp"%><%@include file="../private/babelfy.jsp"%><h1><%=request.getParameter("oid")%></h1>

<%

String body = "- abgeschlossene kaufm�nnische Ausbildung (z. B. B�rokauffrau/-mann, Staatl. Gepr�fte/r Betriebswirt/in, Betriebswirt/in (VWA) oder im Verwaltungsbereich (z.B. Verwaltungsfachangestellte/r)"
 + "- erste Berufserfahrungen im Bereich Controlling"
 + "- anwendungsbereite und aktuelle Grundkenntnisse im Steuerrecht"
 + "- Kenntnisse des kameralen und des kaufm�nnischen Rechnungswesens"
 + "- gute Kenntnisse in den g�ngigen MS Office Anwendungen, insbesondere Excel"
 + "- allgemein gutes Zahlenverst�ndnis"
 + "- gute Englischkenntnisse"
 + "- Kommunikations- und Teamf�higkeit";


        
babelfy b = new babelfy();
ArrayList<babelfy.TagWord> col = b.GetTagList(body);


for(babelfy.TagWord o: col){
    out.println("<br/>");
    out.println(o.Count);
    out.println(" - ");
    out.println(o.Word);
    out.println(" - ");
    out.println(o.Url);
    out.println(" - ");
    out.println(o.isconcept);
 out.println(" - ");
 out.println(o.babelres);

}


%>