<%@ page import="edu.uci.ics.crawler4j.crawler.CrawlConfig, edu.uci.ics.crawler4j.crawler.Page,
         edu.uci.ics.crawler4j.fetcher.PageFetchResult, edu.uci.ics.crawler4j.fetcher.PageFetcher,
         edu.uci.ics.crawler4j.parser.HtmlParseData, edu.uci.ics.crawler4j.parser.ParseData,
         edu.uci.ics.crawler4j.parser.Parser, edu.uci.ics.crawler4j.url.WebURL" %>

<%

class Crawler {

  private Parser parser;
  private PageFetcher pageFetcher;

  public Crawler() {
    CrawlConfig config = new CrawlConfig();
    parser = new Parser(config);
    pageFetcher = new PageFetcher(config);
  }

    public String processUrl(String url) {
        String OutputString = "";
        OutputString += url + "<br/>";
        Page page = download(url);
        if (page != null) {
          ParseData parseData = page.getParseData();
          if (parseData != null) {
            if (parseData instanceof HtmlParseData) {
              HtmlParseData htmlParseData = (HtmlParseData) parseData;
              OutputString += "Title: " + htmlParseData.getTitle();
              OutputString += "Text length: " + htmlParseData.getText().length();
              OutputString += "Html length: " + htmlParseData.getHtml().length();
            }
          } else {
            OutputString += "Couldn't parse the content of the page.<br/>";
          }
        } else {
          OutputString += "Couldn't fetch the content of the page.<br/>";
        }
        OutputString += "==============<br/>";

        return OutputString;
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