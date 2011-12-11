<%-- 
    Document   : Clase
    Created on : 19-nov-2011, 15:27:21
    Author     : Camilo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="http://www.unitec.edu/wp-content/themes/unitec/unitec.ico" type="image/x-icon">
        <title>MCVC</title>
        <link rel="stylesheet" type="text/css" href="CSS/reset.css">
        <link rel="stylesheet" type="text/css" href="CSS/structure.css">
        <script type="text/javascript" src="http://staging.tokbox.com/v0.91/js/TB.min.js"></script>
        <script type="text/javascript" charset="utf-8">
            var apiKey = 1127; // OpenTok sample code key. Replace with your own API key.
            var sessionId = "1sdemo00955f8290f8efa648d9347d718f7e06fd"; // Replace with your session ID.
            var token = "devtoken"; // Should not be hard-coded. Add to the page using the OpenTok server-side libraries.

            var subscribers = {};
            var publisher;
            var session;

            var deviceManager;

            // Un-comment either of the following to set automatic logging and exception handling.
            // See the exceptionHandler() method below.
            // TB.setLogLevel(TB.DEBUG);
            TB.addEventListener("exception", exceptionHandler);

            if (TB.checkSystemRequirements() != TB.HAS_REQUIREMENTS) {
                alert("You don't have the minimum requirements to run this application."
                    + "Please upgrade to the latest version of Flash.");
            } else {
                session = TB.initSession(sessionId);

                // Add event listeners to the session
                session.addEventListener("sessionConnected", sessionConnectedHandler);
                session.addEventListener("streamCreated", streamCreatedHandler);
                session.addEventListener("streamDestroyed", streamDestroyedHandler);
                session.addEventListener("streamPropertyChanged", streamPropertyChangedHandler);
                
            }
                
            //--------------------------------------
            //  OPENTOK EVENT HANDLERS
            //--------------------------------------
            function sessionConnectedHandler(event) {
                subscribeToStreams(event.streams);

                deviceManager = TB.initDeviceManager(apiKey);

                show('disconnectLink');
            <%if (request.getParameter("maestro").equals("m")) {%> 
                    show('pubControls');
            <%}%>
                    hide('connectLink');
                }

                function streamCreatedHandler(event) {
                    subscribeToStreams(event.streams);
                }

                function streamDestroyedHandler(event) {
                    var publisherContainer = document.getElementById("opentok_publisher");
                    var videoPanel = document.getElementById("videoPanel");
                    for (i = 0; i < event.streams.length; i++) {
                        var stream = event.streams[i];
                        if (stream.connection.connectionId == session.connection.connectionId) {
                            videoPanel.removeChild(publisherContainer);
                        } else {
                            var streamContainerDiv = document.getElementById("streamContainer" + stream.streamId);
                            if(streamContainerDiv) {
                                videoPanel = document.getElementById("videoPanel")
                                videoPanel.removeChild(streamContainerDiv);
                            }
                        }
                    }
                }
		
                function streamPropertyChangedHandler(event)
                {
                    var stream = event.stream;
                    var audioControls = document.getElementById(stream.streamId + "-audioControls");
                    if (audioControls && event.changedProperty == "hasAudio") {
                        if (event.newValue == true) {
                            audioControls.style.display = "block";
                        } else {
                            audioControls.style.display = "none";
                        }
                    } else if (audioControls && event.changedProperty == "hasVideo") {
                        if (event.newValue == true) {
                            audioControls.style.display = "block";
                        } else {
                            audioControls.style.display = "none";
                        }
                    }
                }

                function exceptionHandler(event) {
                    alert("Exception: " + event.code + "::" + event.message);
                }

                //--------------------------------------
                //  LINK CLICK HANDLERS
                //--------------------------------------

                /*
                If testing the app from the desktop, be sure to check the Flash Player Global Security setting
                to allow the page from communicating with SWF content loaded from the web. For more information,
                see http://www.tokbox.com/opentok/build/tutorials/helloworld.html#localTest
                 */
                function connect() {
                    session.connect(apiKey, token);
                }

                function disconnect() {
                    session.disconnect();
                    hide('disconnectLink');
                    hide('pubControls');
                    hide('unpubControls');
                    hide("videoOff");
                    hide("videoOn");
                    hide("audioOff");
                    hide("audioOn");
                    show('connectLink');
                }

                // Called when user wants to start publishing to the session
                function startPublishing() {
                    if (!publisher) {
                        var containerDiv = document.createElement('div');
                        containerDiv.className = "subscriberContainer";
                        containerDiv.setAttribute('id', 'opentok_publisher');
                        containerDiv.style.float = "left";
                        var videoPanel = document.getElementById("videoPanel");
                        videoPanel.appendChild(containerDiv);
				
                        var publisherDiv = document.createElement('div'); // Create a div for the publisher to replace
                        publisherDiv.setAttribute('id', 'replacement_div')
                        containerDiv.appendChild(publisherDiv);
				
                        var publisherProperties = new Object();
                        if (document.getElementById("pubAudioOnly").checked) {
                            publisherProperties.publishVideo = false;
                        }
                        if (document.getElementById("pubVideoOnly").checked) {
                            publisherProperties.publishAudio = false;
                        }
				
                        publisher = session.publish(publisherDiv.id, publisherProperties); 
                        // Pass the replacement div id to the publish method
                        
            
                        var publisherControlsDiv = getPublisherControls();
                        publisherControlsDiv.style.display = "block";
                        containerDiv.appendChild(publisherControlsDiv);
                       
                        show('unpubControls');
                        hide('pubControls');
                    }
                }

                function stopPublishing() {
                    if (publisher) {
                        session.unpublish(publisher);
                    }
                    publisher = null;

                    show('pubControls');
                    hide('unpubControls');
                }


                //--------------------------------------
                //  HELPER METHODS
                //--------------------------------------
                function subscribeToStreams(streams) {
                    for (i = 0; i < streams.length; i++) {
                        var stream = streams[i];
                        if (stream.connection.connectionId == session.connection.connectionId) {
                            pubAudioOnly = document.getElementById("pubAudioOnly");
                            pubVideoOnly = document.getElementById("pubVideoOnly"); 
                            if (pubVideoOnly.checked) {
                                show("audioOn");
                            } else {
                                show("audioOff");
                            }
                            if (pubAudioOnly.checked) {
                                show("videoOn");
                            } else {
                                show("videoOff");
                            }
                            
                            return;
                        }

                        var containerDiv = document.createElement('div'); // Create a container for the subscriber and its controls
                        containerDiv.className = "subscriberContainer";
                        var divId = stream.streamId;    // Give the div the id of the stream as its id
                        containerDiv.setAttribute('id', 'streamContainer' + divId);
                        var videoPanel = document.getElementById("videoPanel");
                        videoPanel.appendChild(containerDiv);

                        var subscriberDiv = document.createElement('div'); // Create a replacement div for the subscriber
                        subscriberDiv.setAttribute('id', divId);
                        subscriberDiv.style.cssFloat = "top";
                        containerDiv.appendChild(subscriberDiv);
                        subscribers[stream.streamId] = session.subscribe(stream, divId);
                       <%if (request.getParameter("maestro").equals("m")) {%> 
                        var actionDiv = document.createElement('div');
                        var streamId = stream.streamId
                        actionDiv.setAttribute('id', 'action-'+streamId);
                        actionDiv.style.float = "bottom";
                        actionDiv.style.borderStyle = "solid 1px black";
				
                        var audioControlsDisplay;
                        if (stream.hasAudio) {
                            audioControlsDisplay = "block";
                        } else {
                            audioControlsDisplay = "none";
                        }
                        var videoControlsDisplay;
                        if (stream.hasVideo) {
                            videoControlsDisplay = "block";
                        } else {
                            videoControlsDisplay = "none";
                        }
                        actionDiv.innerHTML = 
                            '<span id="' + streamId +'-audioControls" style="display:' + audioControlsDisplay + '"> \
                                        <a href="#" id="'+streamId+'-audioOff" onclick="turnOffHerAudio(\''+streamId+'\');" style="display:block">Turn off audio</a>\
                                   <a href="#" id="'+streamId+'-audioOn" onclick="turnOnHerAudio(\''+streamId+'\')" style="display:none">Turn on audio</a>\
                                   </span> \
                                        <span id="' + streamId +'-videoControls" style="display:' + videoControlsDisplay + '"> \
                                   <a href="#" id="'+streamId+'-videoOff" onclick="turnOffHerVideo(\''+streamId+'\')" style="display:block">Turn off video</a>\
                                   <a href="#" id="'+streamId+'-videoOn" onclick="turnOnHerVideo(\''+streamId+'\')" style="display:none">Turn on video</a>\
                                   </span>';

                        containerDiv.appendChild(actionDiv);
                        <%}%>
                    }
                }

                function getPublisherControls() {
                    sessionControlsDiv = document.createElement('div');
                    sessionControlsDiv.innerHTML = 
                        '<a href="#" id="audioOff" onClick="turnOffMyAudio(); return false;" style="display:none;">Turn off my audio</a>' +
                        '<a href="#" id="audioOn" onClick="turnOnMyAudio(); return false;" style="display:none;">Turn on my audio</a>' +
                        '<a href="#" id="videoOff" onClick="turnOffMyVideo(); return false;" style="display:none;">Turn off my video</a>' +
                        '<a href="#" id="videoOn" onClick="turnOnMyVideo(); return false;" style="display:none;">Turn on my video</a>'
                    return sessionControlsDiv;
                }
                function turnOffHerVideo(streamId) {
                    var subscriber = subscribers[streamId];
                    subscriber.subscribeToVideo(false);

                    hide(streamId+"-videoOff");
                    show(streamId+"-videoOn");
                }

                function turnOnHerVideo(streamId) {
                    var subscriber = subscribers[streamId];
                    subscriber.subscribeToVideo(true);

                    hide(streamId+"-videoOn");
                    show(streamId+"-videoOff");
                }

                function turnOffHerAudio(streamId) {
                    var subscriber = subscribers[streamId];
                    subscriber.subscribeToAudio(false);

                    hide(streamId+"-audioOff");
                    show(streamId+"-audioOn");
                }

                function turnOnHerAudio(streamId) {
                    var subscriber = subscribers[streamId];
                    subscriber.subscribeToAudio(true);

                    hide(streamId+"-audioOn");
                    show(streamId+"-audioOff");
                }

                function turnOffMyVideo() {
                    publisher.publishVideo(false);

                    hide("videoOff");
                    show("videoOn");
                }

                function turnOnMyVideo() {
                    publisher.publishVideo(true);

                    hide("videoOn");
                    show("videoOff");
                }

                function turnOffMyAudio() {
                    publisher.publishAudio(false);

                    hide("audioOff");
                    show("audioOn");
                }

                function turnOnMyAudio() {
                    publisher.publishAudio(true);

                    hide("audioOn");
                    show("audioOff");
                }

                function toggleMicSettings() {
                    deviceManager.showMicSettings = !deviceManager.showMicSettings;
                }

                function toggleCamSettings() {
                    deviceManager.showCamSettings = !deviceManager.showCamSettings;
                }

                //--------------------------------------
                //  UTILITY METHODS
                //--------------------------------------
                function show(id) {
                    document.getElementById(id).style.display = 'block';
                }

                function hide(id) {
                    document.getElementById(id).style.display = 'none';
                }
        </script>

    </head>
    <body>

        <div class="box clase">

            <fieldset class="boxBodyclase">
                <div id="videoPanel" style="display:block"></div> 
            </fieldset>
            <footer style="height: 102px !important;">
                <div id="sessionControls">
                    <input type="button" class="btnnormal" value="Connect" id ="connectLink" onClick="connect()" style="display:block" />
                    <input type="button" class="btnnormal" value="Leave" id ="disconnectLink" onClick="disconnect()" style="display:none" />
                </div>

                <div id ="pubControls" style="display:none">
                    <form id="publishForm"> 
                        <input type="button" class="btnnormal" value="Start Publishing" onClick="startPublishing()" />
                        <input type="radio" id="pubAV" name="pubRad" checked="checked" />&nbsp;Audio/Video&nbsp;&nbsp; 
                        <input type="radio" id="pubAudioOnly" name="pubRad" />&nbsp;Audio-only&nbsp;&nbsp;
                        <input type="radio" id="pubVideoOnly" name="pubRad" />&nbsp;Video-only
                    </form>
                </div>
                <div id ="unpubControls" style="display:none">
                    <input type="button" class="btnnormal" value="Stop Publishing" onClick="stopPublishing()" style="display:block"/>
                </div>
            </footer>



        </div>


    </body>
</html>
