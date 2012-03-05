<%-- 
    Document   : Clase
    Created on : 19-nov-2011, 15:27:21
    Author     : Camilo
--%>

<%@page import="mcvc.face.select.face_tokbox"%>
<%@page import="mcvc.util.Sqlquery"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mcvc.util.SIGNALS"%>
<%@page import="mcvc.hibernate.clases.TblUsuarios"%>
<%@page import="mcvc.hibernate.clases.TblSession"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%if (request.getParameter("token") != null) {%>
<%Sqlquery face = new Sqlquery();%>
<%face_tokbox tokbox = new face_tokbox();%>
<%face.setcurrentSession();%>
<%try {%>
<%boolean ismaestro = face.isMaestro((String) session.getAttribute("usuario"), request.getParameter("token"));%>

<%String sessionId = face.getSessionId(request.getParameter("token"));%>
<%TblSession tblsession = face.getTblsession().get(0);%>
<%TblUsuarios tblUsuarios = face.getUserinfo((String) session.getAttribute("usuario"));%>
<%String maestro = tblsession.getClsMaestro();%>
<%int cupos = tblsession.getClsCupo();%>


<%int n = 1;%>

<%while ((n * n) < cupos) {%>
<%n++;
    }%>

<%if (ismaestro) {%>
<%ArrayList<SIGNALS> signals_arr = new ArrayList<SIGNALS>();%>
<%getServletContext().setAttribute(sessionId, signals_arr);%>
<%}%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%if (session.getAttribute("usuario") == null) {
                response.sendRedirect("index.jsp");
            }%>
        <%@include file="WEB-INF/jspf/CS_CSS_JS.jspf" %>
        <script src="http://static.opentok.com/v0.91/js/TB.min.js" type="text/javascript" charset="utf-8"></script>       
        <script type="text/javascript" charset="utf-8">
            var session = TB.initSession("<%=sessionId%>"); // Sample session ID. 
            var publisher;
            var ocup_alumno = false;
            var ocup_maestro = false;
            session.addEventListener("sessionConnected", sessionConnectedHandler);
            session.addEventListener("streamCreated", streamCreatedHandler);
            session.addEventListener("streamDestroyed", streamDestroyedHandler);
            session.addEventListener("connectionCreated", connectionCreatedHandler);
            session.addEventListener("sessionDisconnected", sessionDisConnectedHandler);
            session.addEventListener("connectionDestroyed", connectionDestroyedHandler);
            session.addEventListener("signalReceived", signalHandler);
            
            $(document).ready(function() {
                $("#disconnectLink").hide();
                $("#pubControls").hide();
                $("#aluControls").hide();
                $("#permitir_hablar").hide();
                $("#parar_hablar").hide();
                $(".stu").width($(".stu").width());
                $("body").width($("body").width());
                $("#clasemain").width($("#clasemain").width());
                 $(".piz").cleditor({width:"99%", height:"100%"});
                 
                
                
            });
            
            function connect(){
              
                
                token ="";
            <%if (ismaestro) {%>
                    token ="<%=tokbox.generateToKenMaestro(sessionId, tblUsuarios)%>";        
            <%} else {%>
                    token="<%=tokbox.generateToKenAlumno(sessionId, tblUsuarios)%>";
            <%}%>
              
                    session.connect(6642061, token);
                    
                }
            
                function disconnect(){
                    session.disconnect();                      
                }
             
                function startPublishing(){
                    if (!publisher) {   
                        
                       
                        var containerDiv = document.createElement('div');
                        containerDiv.className = "subscriberContainer";
                        containerDiv.setAttribute('id', 'opentok_publisher');
                        if(ocup_maestro == false){
                            var videoPanel = document.getElementById("maestro_div");
                            ocup_maestro = true;
                        }else{
                            
                            if(ocup_alumno == false){
                                var videoPanel = document.getElementById("alumno_div");
                                ocup_alumno = true;
                            }
                        }
                        
                        videoPanel.appendChild(containerDiv);
                        var publisherDiv = document.createElement('div'); // Create a div for the publisher to replace
                        publisherDiv.setAttribute('id', 'replacement_div')
                        containerDiv.appendChild(publisherDiv);
            
                        var publisherProperties = new Object();
                        
            <%if (ismaestro) {%>
                        if (document.getElementById("pubAudioOnly").checked) {
                            publisherProperties.publishVideo = false;
                        }
                        if (document.getElementById("pubVideoOnly").checked) {
                            publisherProperties.publishAudio = false;
                        }
                        $.ajax({
                            type: "POST",
                            url: "PublisherProperties",
                            data: "sessionId=<%=sessionId%>&video="+publisherProperties.publishVideo+"&audio="+publisherProperties.publishAudio+"&todo=set",
                            success: function(){
                                publisherProperties.width=100;
                                publisherProperties.height=100;
                                publisher = session.publish(publisherDiv.id, publisherProperties);
                            }
                        });       
            <%} else {%>
                        $.ajax({
                            type: "POST",
                            url: "PublisherProperties",
                            data: "sessionId=<%=sessionId%>&todo=get",
                            dataType: "json",
                            success: function(data){
                                if(data!=null){
                                    var properties = typeof data != 'object' ? JSON.parse(data) : data;
                                    
                                    publisherProperties.publishVideo = properties.video;
                                    publisherProperties.publishAudio = properties.audio;
                                    publisherProperties.width=100;
                                    publisherProperties.height=100;
                                    publisher = session.publish(publisherDiv.id, publisherProperties);
                                }
                            }
                        });
            <%}%>
                        
                        
                        $("#pubControls").hide();
            <%if (!ismaestro) {%>
                        $("#dejar_de_hablar").show();
                        $("#levantar_mano").hide();
            <%} else {%>
                        changeStatus(3);
            <%}%>
                    } 
                }
                        
                function sessionConnectedHandler(event) {
                    subscribeToStreams(event.streams);
                    $("#disconnectLink").show();
                    $("#connectLink").hide();
            <%if (ismaestro) {%>
                    $("#pubControls").show();
                    changeStatus(2);
            <%} else {%>
                    $("#aluControls").show();
                    $("#dejar_de_hablar").hide();
            <%}%>
                   
                
                }
			
                function streamCreatedHandler(event) {
                    subscribeToStreams(event.streams);
                }
                
                function streamDestroyedHandler(event) {
                   
                    var publisherContainer = document.getElementById("opentok_publisher");
                    var videoPanel = document.getElementById("maestro_div");
                    for (i = 0; i < event.streams.length; i++) {
                        var stream = event.streams[i];
                        if (stream.connection.connectionId == session.connection.connectionId) {
                            videoPanel.removeChild(publisherContainer);
                            publisher =null;ocup_maestro =false;
                        } else {
                            var streamContainerDiv = document.getElementById("streamContainer" + stream.streamId);
                            if(streamContainerDiv) {
                                
                                videoPanel = document.getElementById("alumno_div");
                                videoPanel.removeChild(streamContainerDiv);
                                ocup_alumno = false;
                            }
                          
            
                        }
                    }
                    
                }
                
			
                function subscribeToStreams(streams) {
                    
                    for (i = 0; i < streams.length; i++) {
                        
                        var stream = streams[i];
                        if (stream.connection.connectionId != session.connection.connectionId) {
                            var containerDiv = document.createElement('div'); // Create a container for the subscriber and its controls
                            containerDiv.className = "subscriberContainer";
                            var divId = stream.streamId;    // Give the div the id of the stream as its id
                            containerDiv.setAttribute('id', 'streamContainer' + divId);
                            
                            if(ocup_alumno == false){
                                var videoPanel = document.getElementById("alumno_div");  
                                ocup_alumno = true;
                            }else{ 
                                if(ocup_maestro == false){
                                    var videoPanel = document.getElementById("maestro_div");  
                                    ocup_maestro  = true;
                                }
                            }
                            
                            videoPanel.appendChild(containerDiv);
                            var publisherProperties = new Object();
                            publisherProperties.width=100;
                            publisherProperties.height=100;
                            var subscriberDiv = document.createElement('div'); // Create a replacement div for the subscriber
                            subscriberDiv.setAttribute('id', divId);
                            containerDiv.appendChild(subscriberDiv);
                            session.subscribe(stream, divId,publisherProperties);
                            
                        }
                    }
                  
                }
                
                function changeStatus(status)
                {
                    $.ajax({
                        type: "POST",
                        url: "ChangeStatusServlet",
                        data: "token=<%=request.getParameter("token")%>&status="+status,
                        success: function(){
                            switch(status){
                                case 2 : alert("Se cambio el status a: Activa");
                                    break;
                                case 3 : alert("Se cambio el status a: En Proceso");
                                    break;
                                case 4 : alert("Se cambio el status a: Terminada");
                                    window.location.replace("Home.jsp");
                                    break;
                                    
                            }  
                        }
                    });
     
                }
                
                function connectionCreatedHandler(event) {
            <%if (ismaestro) {%>
                    var foundit = false;
                    for(var j=0;j<event.connections.length;j++){
                        var connectiondata = getConnectionData(event.connections[j]);
                        for(var a=0;a < 3;a++){
                            for(var s=0;s < 7;s++){
                                if($("#alu_"+a+"_"+s+" .email").val()== connectiondata[0] && foundit == false){
                                    
                                    $("#alu_"+a+"_"+s+" .connectionid").val(event.connections[j].connectionId); 
                                    $("#alu_"+a+"_"+s+" .CONNECT").val("SI"); 
                                    
                                    foundit = true;
                                    break;
                                }
                            }
                            
                        }
                        
                        if(foundit==false){
                            for(var a=0;a < 3;a++){
                                for(var s=0;s < 7;s++){
                                    if($("#alu_"+a+"_"+s+" .email").val()== "" && foundit == false){
                                        $("#alu_"+a+"_"+s+" .connectionid").val(event.connections[j].connectionId);
                                        $("#alu_"+a+"_"+s+" .email").val(connectiondata[0]);
                                        $("#alu_"+a+"_"+s+" .username").text(connectiondata[1]);
                                        $("#alu_"+a+"_"+s+" .pa").text(" "+connectiondata[2][0]+".");
                                        $("#alu_"+a+"_"+s+" .sa").val(connectiondata[3]);
                                        $("#alu_"+a+"_"+s+" .telefono").val(connectiondata[4]);
                                        $("#alu_"+a+"_"+s+" .celular").val(connectiondata[5]);
                                        $("#alu_"+a+"_"+s+" .CONNECT").val("SI"); 
                                        $("#alu_"+a+"_"+s+" .count_participacion").text("0"); 
                                        foundit = true;
                                        break;
                                    }
                                }
                            
                            } 
                            
                        }
                       
                        
                        
                    }
                         
            <%}%>
                   
                   
                }
                          
                function getConnectionData(connection) {
			
                    var connectionData = connection.data.split(',')
                        
                    return connectionData;
                }
            
            
                function sessionDisConnectedHandler(event) { 
                
            <%if (ismaestro) {%>
                    changeStatus(4);
            <%} else {%>
                    window.location.replace("Home.jsp");
            <%}%>
                }
                
                function connectionDestroyedHandler(event) {
                    
            <%if (ismaestro) {%>
                   
                
                    var foundit = false;
                    for(var j=0;j<event.connections.length;j++){
                        
                        for (var a = 0 ; a < 3 ;a++){
                            for(var s = 0; s < 7; s++){
                                if(event.connections[j].connectionId==$("#alu_"+a+"_"+s+" .connectionid").val() && foundit == false){
                            
                                    $("#alu_"+a+"_"+s).attr("class","backR stu");
                                    $("#alu_"+a+"_"+s+ ".CONNECT").val("NO");
                                    foundit = true;
                            
                                }
                                
                            }
                            
                        }
              
                    }
            <%}%>
                }
            
                function LevantarMano(){
                    $.ajax({
                        type: "POST",
                        url: "ServletSignals",
                        data: "sessionId=<%=sessionId%>&sender=<%=tblUsuarios.getUsrEmail()%>&reciver=<%=maestro%>&type=1",
                        success: function(){
                            session.signal();
                            $("#levantar_mano").hide();
                        }
                    });
                
                }
            
                function signalHandler(event) {
                    if(event.fromConnection.connectionId != session.connection.connectionId){
                        $.ajax({
                            type: "POST",
                            url: "ServletSiganlR",
                            data: "sessionId=<%=sessionId%>&reciver=<%=tblUsuarios.getUsrEmail()%>",
                            dataType: "json",
                            success: function(data){
                                if(data!=null){
                                    var señales = typeof data != 'object' ? JSON.parse(data) : data;
                                    for(var i=0;i<señales.length;i++){
                                        
                                        if(señales[i].reciber == "<%=tblUsuarios.getUsrEmail()%>"){
                                            if(señales[i].type== 1){
                                                var id = fintd(señales[i].sender);
                                                if(id != ""){
                                                    $(id+" .permitir_participar").val("SI")
                                         
                                                    $(id).attr("class","backG stu");
                                                }
                                       
                                            }
                                            if(señales[i].type == 2){
                                                startPublishing();
                                            }
                                            if(señales[i].type == 3){
                                                session.unpublish(publisher);                                              
                                            }
                                            if(señales[i].type == 4){
                                                var id = fintd(señales[i].sender);
                                                parar(id);
                                            }
                                            if(señales[i].type == 5){
                                                $("#dejar_de_hablar").hide();
                                                $("#levantar_mano").show();
                                                
                                            }
                                        }
                                   
                                    }
                                }  
                            }
                        });
                    }
                }
                
                function fintd(email){

                    var id = ""
                    
                    for(var i =0;i<3;i++){
                        for(var j=0;j<7;j++){
                            id = "#alu_"+i+"_"+j;
                            if( $(id+" .email").val() == email){
                                return id;
                            }
                        }
                    }
                    return "";
                }
                
                function findtd_id(connectionid){
               
                    var id = ""
                    
                    for(var i =0;i<3;i++){
                        for(var j=0;j<7;j++){
                            id = "#alu_"+i+"_"+j;
                            if( $(id+" .connectionid").val() == connectionid){
                                return id;
                            }
                        }
                    }
                    return "";
                    
                }

            
                function permitirhablar(id){
                    var email = $(id+" .email").val();
                    $.ajax({
                        type: "POST",
                        url: "ServletSignals",
                        data: "sessionId=<%=sessionId%>&sender=<%=tblUsuarios.getUsrEmail()%>&reciver="+email+"&type=2",
                        success: function(){
                            $("#permitir_hablar").hide();
                            $("#parar_hablar").attr("onclick", "parar('"+id+"')");
                            $("#parar_hablar").show();
                            $(id+" .participando").val("SI");
                            $(id+" .permitir_participar").val("NO");
                            var count = $(id+" .count_participacion").text();
                            count ++;
                            $(id+" .count_participacion").text(count);
                            $(id).attr("style","background-color: #01a0c7;border: 1px solid #000; cursor: pointer");
              
                            for(var i =0;i<3;i++){
                                for(var j=0;j<7;j++){
                                    var id_ = "#alu_"+i+"_"+j;
                                    if(id_==id){
                                        $(id_+" .BLOCK").val("NO"); 
                                    }else{
                                        $(id_+" .BLOCK").val("SI");  
                                    }
                                }
                            }
                            session.signal();
                        }
                    });  
                }
                
                function parar(id){
                    var email = $(id+" .email").val();
                    $.ajax({
                        type: "POST",
                        url: "ServletSignals",
                        data: "sessionId=<%=sessionId%>&sender=<%=tblUsuarios.getUsrEmail()%>&reciver="+email+"&type=3",
                        success: function(){
                            $("#permitir_hablar").hide();
                            $("#parar_hablar").attr("onclick", "");
                            $("#parar_hablar").hide();
                       
                            for(var i =0;i<3;i++){
                                for(var j=0;j<7;j++){
                                    var id_ = "#alu_"+i+"_"+j;
                                    $(id_+" .BLOCK").val("NO");
                                    $(id_+" .permitir_participar").val("NO");
                                    $(id_+" .participando").val("NO");
                                    if( $(id_+" .CONNECT").val()=="SI"){
                                        $(id_).attr("style","background-color: #e5e5e5;border: 1px solid #000; cursor: pointer");  
                                    }
                                    $.ajax({
                                        type: "POST",
                                        url: "ServletSignals",
                                        data: "sessionId=<%=sessionId%>&sender=<%=tblUsuarios.getUsrEmail()%>&reciver="+$(id_+" .email").val()+"&type=5"});
                                    
                                }
                            }
                            session.signal();
                        }
                    });
                }
                
                function BajarMano(){
                    $.ajax({
                        type: "POST",
                        url: "ServletSignals",
                        data: "sessionId=<%=sessionId%>&sender=<%=tblUsuarios.getUsrEmail()%>&reciver=<%=maestro%>&type=4",
                        success: function(){
                            session.signal();
                            $("#dejar_de_hablar").hide();
                            $("#levantar_mano").show();
                        }
                    });
                   
                }
                $(function() {
		$( "#tabs" ).tabs();
	});
            
        </script>

    </head>
    <body>
        <div id="clasemain">           
            <fieldset class="boxBodyclase">
                <table style="width: 100%;height: 100%">
                    <tr>
                        <td style="height: 100px">
                            <table style="width: 100%;height: 100px" id="cuadricula">
                                <%for (int i = 0; i < 3; i++) {%>
                                <tr >
                                    <%for (int j = 0; j < 7; j++) {%> 
                                    <td style="height: 30px;padding-top: 3px;white-space: nowrap;">
                                        <div style="text-align: center;" class="backW stu" id="alu_<%=String.valueOf(i) + "_" + String.valueOf(j)%>">
                                            <input type="hidden" class="connectionid" value=""/>
                                            <input type="hidden" class="email" value=""/>
                                            <input type="hidden" class="sa" value=""/>
                                            <input type="hidden" class="telefono" value=""/>
                                            <input type="hidden" class="celular" value=""/>
                                            <input type="hidden" class="permitir_participar" value="NO" />
                                            <input type="hidden" class="participando" value="NO" />
                                            <input type="hidden" class="BLOCK" value="NO" />
                                            <input type="hidden" class="CONNECT" value="NO" />

                                            <table style="width: 100%">
                                                <tr><td><label class="username"></label><label class="pa"></label></td></tr>
                                                <tr><td><label class="count_participacion"></label></td></tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%}%>
                                </tr>
                                <%}%>

                            </table>
                        </td> 
                    </tr>
                    <tr>
                        <td>
                            <table style="width: 100%;height: 100%">
                                <tr>
                                    <td style="width: 100px;height: 200px">
                                        <div id="videoPanel">
                                            <table style="width: 100px;height: 200px" >
                                                <tr>
                                                    <td style="width: 100px;border: 1px solid #000">
                                                        <div id="maestro_div">

                                                        </div> 
                                                    </td>

                                                </tr>
                                                <tr>
                                                    <td style="width: 100px;border: 1px solid #000">
                                                        <div id="alumno_div">

                                                        </div>
                                                    </td>
                                                </tr>

                                            </table>
                                        </div> 
                                    </td>
                                    <td style="height: 100%">
                                        <div style="height: 100%;margin:10px 5px 5px 5px">
                                            <div id="tabs"style="height: 95%">
                                                <ul>
                                                    <li><a href="#tabs-1">1</a></li>
                                                    <li><a href="#tabs-2">2</a></li>
                                                    <li><a href="#tabs-3">3</a></li>
                                                </ul>
                                                <div id="tabs-1" style="height: 80%">
                                                    <textarea class="piz" name="input"></textarea>
                                                </div>
                                                <div id="tabs-2" style="height: 80%">
                                                    <textarea class="piz" name="input"></textarea>
                                                </div>
                                                <div id="tabs-3" style="height: 80%">
                                                    <textarea class="piz" name="input"></textarea>
                                                </div>

                                            </div>
                                    </td>
                                </tr>
                            </table>  
                        </td>
                    </tr>

                </table>





            </fieldset>
            <footer >
                <table style="height: 100%;">
                    <tr>
                        <td style="vertical-align:middle;">
                            <div id="sessionControls">
                                <input type="button" class="btnnormal2" value="Connect" id ="connectLink" onClick="connect()" />
                                <input type="button" class="btnnormal2" value="Leave" id ="disconnectLink" onClick="disconnect()" />
                            </div> 
                        </td>
                        <td style="vertical-align:middle;">
                            <div id ="pubControls">
                                <form id="publishForm"> 
                                    <input type="button" class="btnnormal2" value="Start Publishing" onClick="startPublishing()" />
                                    <input type="radio" id="pubAV" name="pubRad" checked="checked" />&nbsp;Audio/Video&nbsp;&nbsp; 
                                    <input type="radio" id="pubAudioOnly" name="pubRad" />&nbsp;Audio-only&nbsp;&nbsp;
                                    <input type="radio" id="pubVideoOnly" name="pubRad" />&nbsp;Video-only
                                </form>
                            </div>
                        </td>
                        <td style="vertical-align:middle;">
                            <div id="aluControls">
                                <input type="button" class="btnnormal2" value="Levantar Mano" id ="levantar_mano" onClick="LevantarMano()" />
                                <input type="button" class="btnnormal2" value="Dejar de Hablar" id ="dejar_de_hablar" onClick="BajarMano()" />
                            </div>
                        </td>
                    </tr>

                </table>
            </footer>

        </div>      
    </body>
</html>
<%} finally {%>
<%face.closeSession();%>
<%}
    }%>
