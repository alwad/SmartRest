/**
 *  ActiON Dashboard 4.3
 *
 *  Visit Home Page for more information:
 *  http://action-dashboard.github.io/
 *
 *  If you like this app, please support the developer via PayPal: alex.smart.things@gmail.com
 *
 *  Copyright © 2014 Alex Malikov
 *
 *  Support for Foscam and Generic MJPEG video streams by k3v0
 *
 */
definition(
    name: "Web API",
    namespace: "Joe",
    author: "Joe",
    description: "Web API for smart things",
    category: "",
    iconUrl: "http://action-dashboard.github.io/icon.png",
    iconX2Url: "http://action-dashboard.github.io/icon.png",
    oauth: true)


preferences {
	page(name: "selectDevices", title: "Devices", install: false, uninstall: true, nextPage: "viewURL") {
    
        section("About") {
            paragraph "Web Api, a SmartThings web api."
            paragraph "Version 1.0\n\n" 
			href url:"http://url", style:"embedded", required:false, title:"More information...", description:"http://url"
        }
		
		section("Things...") {
			href "controlThings", title:"View and control these things"
		}
		
		section("More Tiles and Preferences...") {
			href "moreTiles", title:"Hello, Home!, Mode, Clock, Title, etc"
		}
		
		section("Authentication...") {
			href "authenticationPreferences", title:"Authentication"
		}
    }
	
	page(name: "controlThings", title: "controlThings")
	page(name: "moreTiles", title: "moreTiles")
	page(name: "authenticationPreferences", title: "authenticationPreferences")
	page(name: "viewURL", title: "viewURL")
}

def controlThings() {
	dynamicPage(name: "controlThings", title: "Things", install:false) {
		section("Control these things...") {
			input "holiday", "capability.switch", title: "Which Holiday Lights?", multiple: true, required: false
			input "switches", "capability.switch", title: "Which Switches?", multiple: true, required: false
			input "dimmers", "capability.switchLevel", title: "Which Dimmers?", multiple: true, required: false
			input "momentaries", "capability.momentary", title: "Which Momentary Switches?", multiple: true, required: false
			input "locks", "capability.lock", title: "Which Locks?", multiple: true, required: false
			input "camera", "capability.imageCapture", title: "Which Cameras?", multiple: true, required: false
			input "music", "capability.musicPlayer", title: "Which Music Players?", multiple: true, required: false
		}
		
		section("View state of these things...") {
            input "contacts", "capability.contactSensor", title: "Which Contact?", multiple: true, required: false
            input "presence", "capability.presenceSensor", title: "Which Presence?", multiple: true, required: false
            input "temperature", "capability.temperatureMeasurement", title: "Which Temperature?", multiple: true, required: false
            input "humidity", "capability.relativeHumidityMeasurement", title: "Which Hygrometer?", multiple: true, required: false
            input "motion", "capability.motionSensor", title: "Which Motion?", multiple: true, required: false
            input "water", "capability.waterSensor", title: "Which Water Sensors?", multiple: true, required: false
            input "battery", "capability.battery", title: "Which Battery Status?", multiple: true, required: false
            input "energy", "capability.energyMeter", title: "Which Energy Meters?", multiple: true, required: false
            input "power", "capability.powerMeter", title: "Which Power Meters?", multiple: true, required: false
            input "weather", "device.smartweatherStationTile", title: "Which Weather?", multiple: true, required: false
        }
	}
}

def moreTiles() {
	dynamicPage(name: "moreTiles", title: "More Tiles and Preferences...", install:false) {
		section("Show more tiles...") {
			input "showMode", title: "Mode", "bool", required: true, defaultValue: true
			input "showHelloHome", title: "Hello, Home! Actions", "bool", required: true, defaultValue: true
			input "showClock", title: "Clock", "enum", multiple: false, required: true, defaultValue: "Small Analog", options: ["Small Analog", "Small Digital", "Large Analog", "Large Digital", "None"]
		}
		
		section("Preferences...") {
			label title: "Title", required: false, defaultValue: "ActiON4"
			input "roundNumbers", title: "Round Off Decimals", "bool", required: true, defaultValue:true
		}
	}
}

def authenticationPreferences() {
	dynamicPage(name: "authenticationPreferences", title: "Authentication", install:false) {
		section("Reset AOuth Access Token...") {
        	paragraph "Activating this option will invalidate access token."
        	input "resetOauth", "bool", title: "Reset AOuth Access Token?", defaultValue: false
        }
	}
}

def viewURL() {
	dynamicPage(name: "viewURL", title: "ActiON Dashboard URL", install:!resetOauth, nextPage: resetOauth ? "viewURL" : null) {
		if (resetOauth) {
			generateURL(null)
			
			section("Reset AOuth Access Token...") {
				paragraph "You chose to reset AOuth Access Token in ActiON Dashboard preferences."
				href "authenticationPreferences", title:"Reset AOuth Access Token", description: "Tap to set this option to \"OFF\""
			}
		} else {
			section("View URL for this ActiON Dashboard") {
				href url:"${generateURL("link").join()}", style:"embedded", required:false, title:"${app.label ?: location.name} Dashboard URL", description:"Tap to view, then click \"Done\""
			}
			
			section("Send text message to...") {
				paragraph "Optionally, send text message containing the ActiON Dashboard URL to this phone number. The URL will be sent in two parts because it's too long."
				input "phone", "phone", title: "Which phone?", required: false
			}
		}
    }
}

mappings {
	if (params.access_token && params.access_token != state.accessToken) {
        path("/command") {action: [GET: "oauthError"]}
        path("/data") {action: [GET: "oauthError"]}
        path("/link") {action: [GET: "oauthError"]}
	} else if (!params.access_token) {
        path("/command") {action: [GET: "command"]}
        path("/data") {action: [GET: "allDeviceData"]}
        path("/link") {action: [GET: "viewLinkError"]}
	} else {
        path("/command") {action: [GET: "command"]}
        path("/data") {action: [GET: "allDeviceData"]}
        path("/link") {action: [GET: "link"]}
    }
}

def oauthError() {[error: "OAuth token is invalid or access has been revoked"]}

def viewLinkError() {[error: "You are not authorized to view OAuth access token"]}

def command() {
	log.debug "command received with params $params"
    
    def id = params.device
    def type = params.type
    def command = params.command
	def value = params.value

	def device
    
	if (type == "switch") {
		device = switches?.find{it.id == id}
		if (device) {
			if(device.currentValue('switch') == "on") {
				device.off()
			} else {
				device.on()
			}
		}
	} else if (type == "holiday") {
		device = holiday?.find{it.id == id}
		if (device) {
			if(device.currentValue('switch') == "on") {
				device.off()
			} else {
				device.on()
			}
		}
	} else if (type == "lock") {
		device = locks?.find{it.id == id}
		if (device) {
			if(device.currentValue('lock') == "locked") {
                device.unlock()
            } else {
                device.lock()
            }
		}
	} else if (type == "dimmer") {
		device = dimmers?.find{it.id == id}
		if (device) {
			if (command == "toggle") {
				if(device.currentValue('switch') == "on") {
					device.off()
				} else {
					device.setLevel(Math.min((value as Integer) * 10, 99))
				}
			} else if (command == "level") {
				device.setLevel(Math.min((value as Integer) * 10, 99))
			}
		}
    } else if (type == "mode") {
		setLocationMode(command)
	} else if (type == "helloHome") {
        log.debug "executing Hello Home '$value'"
    	location.helloHome.execute(command)
    } else if (type == "momentary") {
    	momentaries?.find{it.id == id}?.push()
    } else if (type == "camera") {
    	camera?.find{it.id == id}.take()
    } else if (type == "music") {
		device = music?.find{it.id == id}
		if (device) {
			if (command == "level") {
				device.setLevel(Math.min((value as Integer) * 10, 99))
			} else {
				device."$command"()
			}
		}
	}
    
	[status:"ok"]
}

def installed() {
	log.debug "Installed with settings: ${settings}"
	initialize()
}

def updated() {
	log.debug "Updated with settings: ${settings}"
	unsubscribe()
	initialize()
}

def initialize() {
    scheduledWeatherRefresh()
    getURL("ui")
	
	updateStateTS()
	
	subscribe(location, handler)
	subscribe(holiday, "switch.on", handler, [filterEvents: false])
	subscribe(holiday, "switch.off", handler, [filterEvents: false])
	subscribe(holiday, "switch", handler, [filterEvents: false])
	subscribe(holiday, "level", handler, [filterEvents: false])
    subscribe(switches, "switch", handler, [filterEvents: false])
    subscribe(dimmers, "level", handler, [filterEvents: false])
	subscribe(dimmers, "switch", handler, [filterEvents: false])
    subscribe(locks, "lock", handler, [filterEvents: false])
    subscribe(contacts, "contact", handler, [filterEvents: false])
    subscribe(presence, "presence", handler, [filterEvents: false])
    subscribe(temperature, "temperature", handler, [filterEvents: false])
    subscribe(humidity, "humidity", handler, [filterEvents: false])
    subscribe(motion, "motion", handler, [filterEvents: false])
    subscribe(water, "water", handler, [filterEvents: false])
    subscribe(battery, "battery", handler, [filterEvents: false])
    subscribe(energy, "energy", handler, [filterEvents: false])
    subscribe(power, "power", handler, [filterEvents: false])

	subscribe(music, "status", handler, [filterEvents: false])
	subscribe(music, "level", handler, [filterEvents: false])
	subscribe(music, "trackDescription", handler, [filterEvents: false])
	subscribe(music, "mute", handler, [filterEvents: false])
}

def getURL(path) {
	generateURL(path)
	if (state.accessToken) {
		log.info "${title ?: location.name} Web API URL: ${generateURL("ui").join()}"
		if (phone) {
			sendSmsMessage(phone, generateURL(path)[0])
			sendSmsMessage(phone, generateURL(path)[1])
		}
	}
}

def generateURL(path) {
	log.debug "resetOauth: $resetOauth"
	if (resetOauth) {
    	log.debug "Reseting Access Token"
    	state.accessToken = null
    }
    
	if (!resetOauth && !state.accessToken) {
    	try {
			createAccessToken()
			log.debug "Creating new Access Token: $state.accessToken"
		} catch (ex) {
			log.error "Did you forget to enable OAuth in SmartApp IDE settings for Web API Dashboard?"
			log.error ex
		}
    }
	
	["https://graph.api.smartthings.com/api/smartapps/installations/${app.id}/$path", "?access_token=${state.accessToken}"]
}

def scheduledWeatherRefresh() {
    runIn(3600, scheduledWeatherRefresh, [overwrite: false])
	weather?.refresh()
    state.lastWeatherRefresh = getTS()
	updateStateTS()
}


def getTS() {
	def tf = new java.text.SimpleDateFormat("h:mm a")
    if (location?.timeZone) tf.setTimeZone(location.timeZone)
    "${tf.format(new Date())}"
}

def getDate() {
	def tf = new java.text.SimpleDateFormat("MMMMM d")
    if (location?.timeZone) tf.setTimeZone(location.timeZone)
    "${tf.format(new Date())}"
}

def getDOW() {
	def tf = new java.text.SimpleDateFormat("EEEE")
    if (location?.timeZone) tf.setTimeZone(location.timeZone)
    "${tf.format(new Date())}"
}


def roundNumber(num) {
	if (!roundNumbers || !"$num".isNumber()) return num
	if (num == null || num == "") return "n/a"
	else {
    	try {
            return "$num".toDouble().round()
        } catch (e) {return num}
    }
}

def getWeatherData(device) {
	def data = [tile:"device", active:"inactive", type: "weather", device: device.id]
    ["city", "weather", "feelsLike", "temperature", "localSunrise", "localSunset", "percentPrecip", "humidity", "weatherIcon"].each{data["$it"] = device?.currentValue("$it")}
    data.icon = ["chanceflurries":"wi-snow","chancerain":"wi-rain","chancesleet":"wi-rain-mix","chancesnow":"wi-snow","chancetstorms":"wi-storm-showers","clear":"wi-day-sunny","cloudy":"wi-cloudy","flurries":"wi-snow","fog":"wi-fog","hazy":"wi-dust","mostlycloudy":"wi-cloudy","mostlysunny":"wi-day-sunny","partlycloudy":"wi-day-cloudy","partlysunny":"wi-day-cloudy","rain":"wi-rai","sleet":"wi-rain-mix","snow":"wi-snow","sunny":"wi-day-sunny","tstorms":"wi-storm-showers","nt_chanceflurries":"wi-snow","nt_chancerain":"wi-rain","nt_chancesleet":"wi-rain-mix","nt_chancesnow":"wi-snow","nt_chancetstorms":"wi-storm-showers","nt_clear":"wi-stars","nt_cloudy":"wi-cloudy","nt_flurries":"wi-snow","nt_fog":"wi-fog","nt_hazy":"wi-dust","nt_mostlycloudy":"wi-night-cloudy","nt_mostlysunny":"wi-night-cloudy","nt_partlycloudy":"wi-night-cloudy","nt_partlysunny":"wi-night-cloudy","nt_sleet":"wi-rain-mix","nt_rain":"wi-rain","nt_snow":"wi-snow","nt_sunny":"wi-night-clear","nt_tstorms":"wi-storm-showers","wi-horizon":"wi-horizon"][data.weatherIcon]
	data
}

def renderTile(data) {
	if (data.type == "weather"){
		return """<div class="weather tile w2" data-type="weather" data-device="$data.device" data-weather='${data.encodeAsJSON()}'></div>"""
	} else if (data.type == "music") {
		return """
		<div class="music tile w2 $data.active ${data.mute ? "muted" : ""}" data-type="music" data-device="$data.device" data-level="$data.level" data-track-description="$data.trackDescription" data-mute="$data.mute">
			<div class="title"><span class="name">$data.name</span><br/><span class='title2 track'>$data.trackDescription</span></div>
			<div class="icon text"><i class="fa fa-fw fa-backward back"></i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="fa fa-fw fa-pause pause"></i><i class="fa fa-fw fa-play play"></i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i class="fa fa-fw fa-forward forward"></i></div>
			<div class="footer"><i class='fa fa-fw fa-volume-down unmuted'></i><i class='fa fa-fw fa-volume-off muted'></i></div>
		</div>
		"""
	} else if (data.tile == "device") {
		return """<div class="$data.type tile $data.active" data-active="$data.active" data-type="$data.type" data-device="$data.device" data-value="$data.value" data-level="$data.level" data-is-value="$data.isValue"><div class="title">$data.name</div></div>"""
	} else if (data.tile == "link") {
		return """<div class="link tile" data-link-i="$data.i"><div class="title">$data.title</div><div class="icon"><a href="$data.link" data-ajax="false" style="color:white"><i class="fa fa-link"></i></a></div></div>"""
	} else if (data.tile == "video") {
		return """<div class="video tile h2 w2" data-link-i="$data.i"><div class="title">$data.title</div><div class="icon" style="margin-top:-82px;"><object width="240" height="164"><param name="movie" value="$data.link"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><param name="wmode" value="opaque"></param><embed src="$data.link" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="240" height="164" wmode="opaque"></embed></object></div></div>"""
	} else if (data.tile == "genericMJPEGvideo") {
		return """<div class="video tile h2 w2" data-link-i="$data.i"><div class="title">$data.title</div><div class="icon" style="margin-top:-82px;"><object width="240" height="164"><img src="$data.link" width="240" height="164"></object></div></div>"""
	} else if (data.tile == "refresh") {
		return """<div class="refresh tile clickable"><div class="title">Refresh</div><div class="footer">Updated $data.ts</div></div>"""
	} else if (data.tile == "mode") {
		return renderModeTile(data)
	} else if (data.tile == "clock") {
		if (data.type == "a") {
			return """<div id="analog-clock" class="clock tile clickable h$data.size w$data.size"><div class="title">$data.date</div><div class="icon" style="margin-top:-${data.size * 45}px;"><canvas id="clockid" class="CoolClock:st:${45 * data.size}"></canvas></div><div class="footer">$data.dow</div></div>"""
		} else {
			return """<div id="digital-clock" class="clock tile clickable w$data.size"><div class="title">$data.date</div><div class="icon ${data.size == 2 ? "" : "text"}" id="clock">*</div><div class="footer">$data.dow</div></div>"""
		}
	} else if (data.tile == "helloHome") {
		return renderHelloHomeTile(data)
	}
	
	return ""
}

def getMusicPlayerData(device) {[tile: "device", type: "music", device: device.id, name: device.displayName, status: device.currentValue("status"), level: getDeviceLevel(device, "music"), trackDescription: device.currentValue("trackDescription"), mute: device.currentValue("mute") == "muted", active: device.currentValue("status") == "playing" ? "active" : ""]}

/*
 *
 * Device API mapper 
 *
 */
def getDeviceData(device, type) {
  [
    tile: "device",  
    active: isActive(device, type), 
    type: type, 
    device: device.id, 
    name: device.displayName, 
    value: getDeviceValue(device, type), level: getDeviceLevel(device, type), isValue: isValue(device, type)
  ]
}

def getDeviceFieldMap() {[lock: "lock", holiday: "switch", "switch": "switch", dimmer: "switch", contact: "contact", presence: "presence", temperature: "temperature", humidity: "humidity", motion: "motion", water: "water", power: "power", energy: "energy", battery: "battery"]}

def getActiveDeviceMap() {[lock: "unlocked", holiday: "on", "switch": "on", dimmer: "on", contact: "open", presence: "present", motion: "active", water: "wet"]}

def isValue(device, type) {!(["momentary", "camera"] << getActiveDeviceMap().keySet()).flatten().contains(type)}

def isActive(device, type) {
	def field = getDeviceFieldMap()[type]
	def value = "n/a"
	try {
		value = device.respondsTo("currentValue") ? device.currentValue(field) : device.value
	} catch (e) {
		log.error "Device $device ($type) does not report $field properly. This is probably due to numerical value returned as text"
	}
	value == getActiveDeviceMap()[type] ? "active" : "inactive"
}

def getDeviceValue(device, type) {
	def unitMap = [temperature: "°", humidity: "%", battery: "%", power: "W", energy: "kWh"]
	def field = getDeviceFieldMap()[type]
	def value = "n/a"
	try {
		value = device.respondsTo("currentValue") ? device.currentValue(field) : device.value
	} catch (e) {
		log.error "Device $device ($type) does not report $field properly. This is probably due to numerical value returned as text"
	}
	if (!isValue(device, type)) return value
	else return "${roundNumber(value)}${unitMap[type] ?: ""}"
}

def getDeviceLevel(device, type) {
if (type == "dimmer" ||  type == "music") return "${(device.currentValue("level") ?: 0) / 10.0}".toDouble().round() ?: 1}

def handler(e) {
	log.debug "event happened $e.description"
	updateStateTS()
}

def updateStateTS() {state.ts = now()}

def getStateTS() {state.ts}


def allDeviceData() {
	def data = []
	
	if (showMode && location.modes) data << [tile: "mode", mode: "$location.mode", isStandardMode: ("$location.mode" == "Home" || "$location.mode" == "Away" || "$location.mode" == "Night"), modes: location?.modes?.name?.sort()]
	
	def phrases = location?.helloHome?.getPhrases()*.label?.sort()
	if (showHelloHome && phrases) data << [tile: "helloHome", phrases: phrases]
	
	weather?.each{data << getWeatherData(it)}
	
	holiday?.each{data << getDeviceData(it, "holiday")}
	locks?.each{data << getDeviceData(it, "lock")}
	music?.each{data << getMusicPlayerData(it)}
	switches?.each{data << getDeviceData(it, "switch")}
	dimmers?.each{data << getDeviceData(it, "dimmer")}
	momentaries?.each{data << getDeviceData(it, "momentary")}
	contacts?.each{data << getDeviceData(it, "contact")}
	presence?.each{data << getDeviceData(it, "presence")}
	motion?.each{data << getDeviceData(it, "motion")}
	camera?.each{data << getDeviceData(it, "camera")}
	(1..10).each{if (settings["dropcamStreamUrl$it"]) {data << [tile: "video", link: settings["dropcamStreamUrl$it"], title: settings["dropcamStreamT$it"] ?: "Stream $it", i: it]}}
	(1..10).each{if (settings["mjpegStreamUrl$it"]) {data << [tile: "genericMJPEGvideo", link: settings["mjpegStreamUrl$it"], title: settings["mjpegStreamTitile$it"] ?: "Stream $it", i: it]}}
	temperature?.each{data << getDeviceData(it, "temperature")}
	humidity?.each{data << getDeviceData(it, "humidity")}
	water?.each{data << getDeviceData(it, "water")}
	energy?.each{data << getDeviceData(it, "energy")}
	power?.each{data << getDeviceData(it, "power")}
	battery?.each{data << getDeviceData(it, "battery")}
	
	(1..10).each{if (settings["linkUrl$it"]) {data << [tile: "link", link: settings["linkUrl$it"], title: settings["linkTitle$it"] ?: "Link $it", i: it]}}

	data
}


def link() {render contentType: "text/html", data: """<!DOCTYPE html><html><head></head><body>${title ?: location.name} ActiON Dashboard URL:<br/><textarea rows="9" cols="30" style="font-size:10px;">${generateURL("ui").join()}</textarea><br/><br/>Copy the URL above and click Done.<br/></body></html>"""}

