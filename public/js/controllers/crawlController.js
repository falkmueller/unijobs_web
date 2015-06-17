(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('crawlController', function($scope){
             $scope.Crawl = function(WsPw){
                 $("#divWaitCrawl").show();
                $.ajax({
                    url: "webservice.jsp",
                    method: "GET",
                    data: {function: "crawl", WsPw: WsPw},
                    dataType: "json",
                    success: function(res){
                         $("#divWaitCrawl").hide();
                        if (res.success){
                            AddMessage('AddJob','Die Seiten wurden gecrawled','success');  
                            $scope.$apply(function () {
                                    $scope.crawledSites = res.data;
                            });
                        } else {
                            AddMessage('AddJob',res.message,'danger');  
                        }
                    },
                    error: function(res){
                        AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    }
                  });
             };
             
             $scope.Parse = function(WsPw){
                 $("#divWaitParse").show();
                 $.ajax({
                    url: "webservice.jsp",
                    method: "GET",
                    data: {function: "parse", WsPw: WsPw},
                    dataType: "json",
                    success: function(res){
                        console.log(res);
                        $("#divWaitParse").hide();
                        if (res.success){
                            AddMessage('AddJob','Die Seiten wurden geparsed','success');  
                            $scope.$apply(function () {
                                    $scope.parseRsult = res.data;
                            });
                        } else {
                            AddMessage('AddJob',res.message,'danger');  
                        }
                    },
                    error: function(res){
                        AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    }
                  });
             };
        });
    });
}(define));