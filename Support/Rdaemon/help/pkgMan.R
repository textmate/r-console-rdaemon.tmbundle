f0815<-function(){
loaded.pkgs <- .packages()
x <- library()
x <- x$results[x$results[, 1] != "base", ]
pkgsraw <- x[, 1]
if(getRversion() >= "2.10.0") {
theport <- ifelse(!tools:::httpdPort,tools::startDynamicHelp(T),tools:::httpdPort)
pkgs <- paste("<td class=point onclick=\"show('http://127.0.0.1:", theport, "/library/", pkgsraw, "/html/00Index.html", "')\">", x[, 1], "</td>", sep="")
pkgs.desc <- paste("<td class=point onclick=\"show('http://127.0.0.1:", theport, "/library/", pkgsraw, "/html/00Index.html", "')\">",x[, 3],"</td>",sep="")
} else {
pkgs <- paste("<td class=point onclick=\"show('file://", file.path(.find.package(pkgsraw), "html", "00Index.html"), "')\">",x[, 1],"</td>",sep="")
pkgs.desc <- paste("<td class=point onclick=\"show('file://", file.path(.find.package(pkgsraw), "html", "00Index.html"), "')\">",x[, 3],"</td>",sep="")
}
is.loaded <- !is.na(match(pkgsraw, loaded.pkgs))
pkgs.status <- character(length(is.loaded))
pkgs.status[which(is.loaded)] <- paste("<tr><td align=center><input name=\"",pkgsraw[which(is.loaded)],"\" onchange=\"pkgMan(this);\" type=\"checkbox\" checked></td>",sep="")
pkgs.status[which(!is.loaded)] <- paste("<tr><td align=center><input name=\"",pkgsraw[which(!is.loaded)],"\" onchange=\"pkgMan(this);\" type=\"checkbox\"></td>",sep="")
cat("<span style='font-family:Lucida Grande'><table width=100% border=1 frame=box rules=groups cellspacing=2mm style='margin:2mm; font-size:8pt; collapse:collapse;'><tr><thead bgcolor=lightgrey><td><b>loaded</b><td><b>Package</b><td><b>Description</b><tbody>")
cat(paste(pkgs.status,pkgs,pkgs.desc,sep="\n"))
}
f0815()
cat("</table></span><small>")
rm(f0815)
