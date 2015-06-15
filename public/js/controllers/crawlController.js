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
                    xhrFields: {
                        withCredentials: true
                    },
                    success: function(res){
                        console.log(res);
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
        });
    });
}(define));