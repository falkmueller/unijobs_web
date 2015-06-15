<%@ page import="edu.uci.ics.crawler4j.crawler.CrawlConfig, edu.uci.ics.crawler4j.crawler.Page,
         edu.uci.ics.crawler4j.fetcher.PageFetchResult, edu.uci.ics.crawler4j.fetcher.PageFetcher,
         edu.uci.ics.crawler4j.parser.HtmlParseData, edu.uci.ics.crawler4j.parser.ParseData,
         edu.uci.ics.crawler4j.parser.Parser, edu.uci.ics.crawler4j.url.WebURL,
         java.util.Set, java.util.Iterator, java.util.Date, java.util.HashSet,
         java.io.FileWriter, java.io.IOException, org.json.simple.JSONValue, org.json.simple.JSONObject" %><%

class Crawler {

  private Parser parser;
  private PageFetcher pageFetcher;

  public Crawler() {
    CrawlConfig config = new CrawlConfig();
    parser = new Parser(config);
    pageFetcher = new PageFetcher(config);
  }

    public ParseData processUrl(String url) {
        Page page = download(url);
        if (page != null) {
          ParseData parseData = page.getParseData();
          if (parseData != null) {
            if (parseData instanceof HtmlParseData) {
              return parseData;
            }
          } else {
            //error
          }
        } else {
          //error
        }
        
        return null;
      }

private Page download(String url) {
    WebURL curURL = new WebURL();
    curURL.setURL(url);
    PageFetchResult fetchResult = null;
    try {
      fetchResult = pageFetcher.fetchPage(curURL);
      if (fetchResult.getStatusCode() == 200) {
        Page page = new Page(curURL);
        fetchResult.fetchContent(page);
        parser.parse(page, curURL.getURL());
        return page;
      }
    } catch (Exception e) {
      //out.write("Error occurred while fetching url: " + curURL.getURL(), e);
    } finally {
      if (fetchResult != null) {
        fetchResult.discardContentIfNotConsumed();
      }
    }
    return null;
  }

}

%>