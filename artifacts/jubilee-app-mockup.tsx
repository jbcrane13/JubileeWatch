import React, { useState, useEffect } from 'react';
import { 
  Home, 
  MessageCircle, 
  Map, 
  TrendingUp, 
  Settings, 
  Wind, 
  Droplets, 
  Thermometer, 
  Gauge, 
  AlertCircle, 
  ChevronRight, 
  MapPin, 
  Send, 
  Users, 
  Clock,
  Bell,
  Moon,
  Shield
} from 'lucide-react';

const JubileeApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [jubileeProbability, setJubileeProbability] = useState(65);
  const [showAlert, setShowAlert] = useState(false);
  const [chatMessage, setChatMessage] = useState('');
  const [messages, setMessages] = useState([
    { id: 1, user: 'Sarah M.', message: 'Seeing lots of movement near Fairhope pier!', time: '2 min ago' },
    { id: 2, user: 'Mike D.', message: 'Water temp just dropped 3 degrees in 20 minutes', time: '5 min ago' },
    { id: 3, user: 'You', message: 'Heading out now, conditions look perfect', time: '8 min ago' }
  ]);

  // Simulate real-time data updates
  useEffect(() => {
    const interval = setInterval(() => {
      setJubileeProbability(prev => {
        const change = (Math.random() - 0.5) * 5;
        const newValue = Math.max(0, Math.min(100, prev + change));
        if (newValue > 75 && !showAlert) {
          setShowAlert(true);
          setTimeout(() => setShowAlert(false), 5000);
        }
        return newValue;
      });
    }, 3000);
    return () => clearInterval(interval);
  }, [showAlert]);

  const getProbabilityColor = (probability) => {
    if (probability < 30) return 'text-green-400';
    if (probability < 60) return 'text-yellow-400';
    if (probability < 80) return 'text-orange-400';
    return 'text-red-400';
  };

  const getProbabilityBg = (probability) => {
    if (probability < 30) return 'bg-green-400/20';
    if (probability < 60) return 'bg-yellow-400/20';
    if (probability < 80) return 'bg-orange-400/20';
    return 'bg-red-400/20';
  };

  const getProbabilityText = (probability) => {
    if (probability < 30) return 'Low';
    if (probability < 60) return 'Moderate';
    if (probability < 80) return 'High';
    return 'Critical';
  };

  const sendMessage = () => {
    if (chatMessage.trim()) {
      setMessages([
        { id: messages.length + 1, user: 'You', message: chatMessage, time: 'now' },
        ...messages
      ]);
      setChatMessage('');
    }
  };

  const Dashboard = () => (
    <div className="flex-1 overflow-y-auto pb-20">
      {/* Header */}
      <div className="p-6 pb-4">
        <h1 className="text-3xl font-bold text-white mb-1">JubileeWatch</h1>
        <div className="flex items-center text-gray-400">
          <MapPin className="w-4 h-4 mr-1" />
          <span className="text-sm">Fairhope Municipal Pier</span>
        </div>
      </div>

      {/* Alert Banner */}
      {showAlert && (
        <div className="mx-6 mb-4 p-4 bg-red-500/20 border border-red-500/50 rounded-xl animate-pulse">
          <div className="flex items-center">
            <AlertCircle className="w-5 h-5 text-red-400 mr-2" />
            <span className="text-red-400 font-medium">High Jubilee Probability Detected!</span>
          </div>
        </div>
      )}

      {/* Probability Card */}
      <div className="mx-6 mb-6">
        <div className={`p-6 rounded-2xl ${getProbabilityBg(jubileeProbability)} border border-gray-700`}>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-white">Jubilee Probability</h2>
            <span className={`text-sm font-medium ${getProbabilityColor(jubileeProbability)}`}>
              {getProbabilityText(jubileeProbability)}
            </span>
          </div>
          <div className="relative h-40 flex items-center justify-center">
            <div className="absolute inset-0 flex items-center justify-center">
              <div className={`text-6xl font-bold ${getProbabilityColor(jubileeProbability)}`}>
                {Math.round(jubileeProbability)}%
              </div>
            </div>
            <svg className="absolute inset-0 w-full h-full">
              <circle
                cx="50%"
                cy="50%"
                r="70"
                fill="none"
                stroke="rgba(255,255,255,0.1)"
                strokeWidth="8"
              />
              <circle
                cx="50%"
                cy="50%"
                r="70"
                fill="none"
                stroke="currentColor"
                strokeWidth="8"
                strokeDasharray={`${jubileeProbability * 4.4} 440`}
                transform="rotate(-90 80 80)"
                className={getProbabilityColor(jubileeProbability)}
              />
            </svg>
          </div>
          <p className="text-center text-gray-400 text-sm mt-4">
            Next update in 5 minutes
          </p>
        </div>
      </div>

      {/* Environmental Conditions */}
      <div className="mx-6 mb-6">
        <h2 className="text-xl font-semibold text-white mb-4">Current Conditions</h2>
        <div className="grid grid-cols-2 gap-4">
          <ConditionCard
            icon={<Thermometer className="w-5 h-5" />}
            label="Water Temp"
            value="78°F"
            trend="-2°"
            optimal={true}
          />
          <ConditionCard
            icon={<Wind className="w-5 h-5" />}
            label="Wind"
            value="3 mph"
            trend="SE"
            optimal={true}
          />
          <ConditionCard
            icon={<Droplets className="w-5 h-5" />}
            label="Humidity"
            value="92%"
            trend="+3%"
            optimal={true}
          />
          <ConditionCard
            icon={<Gauge className="w-5 h-5" />}
            label="Pressure"
            value="30.12"
            trend="Steady"
            optimal={false}
          />
        </div>
      </div>

      {/* Recent Activity */}
      <div className="mx-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-white">Recent Activity</h2>
          <button className="text-cyan-400 text-sm">View All</button>
        </div>
        <div className="space-y-3">
          <ActivityCard
            title="Community Alert"
            description="Multiple sightings reported near Point Clear"
            time="15 min ago"
            type="alert"
          />
          <ActivityCard
            title="Conditions Update"
            description="Oxygen levels dropping rapidly"
            time="1 hour ago"
            type="update"
          />
        </div>
      </div>
    </div>
  );

  const Community = () => (
    <div className="flex-1 flex flex-col">
      {/* Header */}
      <div className="p-6 pb-4">
        <h1 className="text-2xl font-bold text-white">Community</h1>
      </div>

      {/* Tab Selection */}
      <div className="flex px-6 mb-4 gap-2">
        <button className="px-4 py-2 bg-cyan-500/20 text-cyan-400 rounded-lg font-medium">
          Live Chat
        </button>
        <button className="px-4 py-2 text-gray-400 rounded-lg font-medium">
          Message Board
        </button>
      </div>

      {/* Chat Area */}
      <div className="flex-1 overflow-y-auto px-6 pb-4">
        <div className="bg-gray-800/50 rounded-xl p-3 mb-4 border border-gray-700">
          <div className="flex items-center text-yellow-400 text-sm">
            <Users className="w-4 h-4 mr-2" />
            <span>47 users online</span>
          </div>
        </div>
        
        <div className="space-y-4">
          {messages.map((msg) => (
            <div key={msg.id} className={`flex ${msg.user === 'You' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-[80%] ${msg.user === 'You' ? 'order-2' : ''}`}>
                <div className="flex items-baseline gap-2 mb-1">
                  <span className="text-sm font-medium text-gray-400">{msg.user}</span>
                  <span className="text-xs text-gray-500">{msg.time}</span>
                </div>
                <div className={`rounded-2xl px-4 py-2 ${
                  msg.user === 'You' 
                    ? 'bg-cyan-500/20 text-cyan-100' 
                    : 'bg-gray-700 text-gray-100'
                }`}>
                  {msg.message}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Message Input */}
      <div className="p-6 pt-2 pb-24">
        <div className="flex gap-2">
          <input
            type="text"
            value={chatMessage}
            onChange={(e) => setChatMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
            placeholder="Type a message..."
            className="flex-1 bg-gray-700 text-white rounded-full px-4 py-3 focus:outline-none focus:ring-2 focus:ring-cyan-500"
          />
          <button
            onClick={sendMessage}
            className="bg-cyan-500 text-white rounded-full p-3 hover:bg-cyan-600 transition-colors"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );

  const MapView = () => (
    <div className="flex-1 relative">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-10 p-6 pb-4 bg-gradient-to-b from-gray-900 to-transparent">
        <h1 className="text-2xl font-bold text-white">Jubilee Map</h1>
      </div>

      {/* Map Placeholder */}
      <div className="absolute inset-0 bg-gray-800">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <Map className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <p className="text-gray-400">Interactive map showing jubilee probability zones</p>
            <p className="text-gray-500 text-sm mt-2">Integration with mapping service required</p>
          </div>
        </div>
        
        {/* Sample Heat Zones */}
        <div className="absolute top-32 left-10 w-32 h-32 bg-red-400/30 rounded-full blur-xl"></div>
        <div className="absolute top-48 right-20 w-24 h-24 bg-yellow-400/20 rounded-full blur-xl"></div>
        <div className="absolute bottom-40 left-20 w-20 h-20 bg-green-400/20 rounded-full blur-xl"></div>
      </div>

      {/* Legend */}
      <div className="absolute bottom-24 left-6 bg-gray-800/90 backdrop-blur rounded-lg p-4 border border-gray-700">
        <h3 className="text-white font-medium mb-2">Probability</h3>
        <div className="space-y-1 text-sm">
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-red-400 rounded"></div>
            <span className="text-gray-300">High (&gt;75%)</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-yellow-400 rounded"></div>
            <span className="text-gray-300">Moderate (30-75%)</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-green-400 rounded"></div>
            <span className="text-gray-300">Low (&lt;30%)</span>
          </div>
        </div>
      </div>
    </div>
  );

  const Trends = () => (
    <div className="flex-1 overflow-y-auto pb-20">
      {/* Header */}
      <div className="p-6 pb-4">
        <h1 className="text-2xl font-bold text-white">Trends & Analytics</h1>
      </div>

      {/* Time Range Selector */}
      <div className="px-6 mb-6">
        <div className="flex gap-2">
          <button className="flex-1 py-2 bg-cyan-500/20 text-cyan-400 rounded-lg font-medium">
            24 Hours
          </button>
          <button className="flex-1 py-2 text-gray-400 rounded-lg font-medium">
            7 Days
          </button>
          <button className="flex-1 py-2 text-gray-400 rounded-lg font-medium">
            30 Days
          </button>
        </div>
      </div>

      {/* Probability Trend Chart */}
      <div className="mx-6 mb-6">
        <div className="bg-gray-800 rounded-xl p-4 border border-gray-700">
          <h3 className="text-white font-medium mb-4">Probability Trend</h3>
          <div className="h-48 relative">
            {/* Simplified chart visualization */}
            <svg className="w-full h-full">
              <polyline
                points="10,120 50,100 90,110 130,60 170,40 210,80 250,70 290,30"
                fill="none"
                stroke="rgb(6, 182, 212)"
                strokeWidth="2"
              />
              <circle cx="290" cy="30" r="4" fill="rgb(6, 182, 212)" />
            </svg>
            <div className="absolute top-0 right-0 text-xs text-gray-400">
              Current: 65%
            </div>
          </div>
        </div>
      </div>

      {/* Environmental Metrics */}
      <div className="mx-6 mb-6">
        <h3 className="text-white font-medium mb-4">Environmental Metrics</h3>
        <div className="space-y-3">
          <MetricRow label="Water Temperature" value="78°F" change="-3.2°" trend="down" />
          <MetricRow label="Dissolved Oxygen" value="3.2 ppm" change="-0.8" trend="down" />
          <MetricRow label="Wind Speed" value="3 mph" change="+1" trend="up" />
          <MetricRow label="Humidity" value="92%" change="+5%" trend="up" />
        </div>
      </div>

      {/* Historical Events */}
      <div className="mx-6 mb-6">
        <h3 className="text-white font-medium mb-4">Recent Jubilee Events</h3>
        <div className="space-y-3">
          <HistoricalEvent
            date="June 28"
            location="Fairhope Pier"
            probability="87%"
            confirmed={true}
          />
          <HistoricalEvent
            date="June 15"
            location="Point Clear"
            probability="92%"
            confirmed={true}
          />
          <HistoricalEvent
            date="June 3"
            location="Battles Wharf"
            probability="78%"
            confirmed={false}
          />
        </div>
      </div>
    </div>
  );

  const SettingsView = () => {
    const [notifications, setNotifications] = useState(true);
    const [highAlerts, setHighAlerts] = useState(true);
    const [darkMode, setDarkMode] = useState(true);

    return (
      <div className="flex-1 overflow-y-auto pb-20">
        {/* Header */}
        <div className="p-6 pb-4">
          <h1 className="text-2xl font-bold text-white">Settings</h1>
        </div>

        {/* Profile Section */}
        <div className="mx-6 mb-6">
          <div className="bg-gray-800 rounded-xl p-4 border border-gray-700 flex items-center">
            <div className="w-16 h-16 bg-gradient-to-br from-cyan-400 to-blue-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
              JD
            </div>
            <div className="ml-4 flex-1">
              <h3 className="text-white font-medium">John Doe</h3>
              <p className="text-gray-400 text-sm">Member since June 2024</p>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </div>
        </div>

        {/* Home Location */}
        <div className="mx-6 mb-6">
          <h3 className="text-white font-medium mb-3">Home Location</h3>
          <div className="bg-gray-800 rounded-xl p-4 border border-gray-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-white">Fairhope Municipal Pier</p>
                <p className="text-gray-400 text-sm">30.5225° N, 87.9035° W</p>
              </div>
              <button className="text-cyan-400 text-sm">Change</button>
            </div>
          </div>
        </div>

        {/* Notifications */}
        <div className="mx-6 mb-6">
          <h3 className="text-white font-medium mb-3">Notifications</h3>
          <div className="space-y-3">
            <SettingToggle
              label="Push Notifications"
              description="Get alerts for jubilee conditions"
              value={notifications}
              onChange={setNotifications}
            />
            <SettingToggle
              label="High Probability Alerts"
              description="Only notify when probability > 75%"
              value={highAlerts}
              onChange={setHighAlerts}
            />
          </div>
        </div>

        {/* Appearance */}
        <div className="mx-6 mb-6">
          <h3 className="text-white font-medium mb-3">Appearance</h3>
          <div className="space-y-3">
            <SettingToggle
              label="Dark Mode"
              description="Easier on the eyes at night"
              value={darkMode}
              onChange={setDarkMode}
            />
          </div>
        </div>

        {/* About */}
        <div className="mx-6 mb-6">
          <h3 className="text-white font-medium mb-3">About</h3>
          <div className="space-y-2">
            <SettingRow label="Version" value="1.0.0" />
            <SettingRow label="Terms of Service" value="" hasArrow />
            <SettingRow label="Privacy Policy" value="" hasArrow />
            <SettingRow label="Contact Support" value="" hasArrow />
          </div>
        </div>

        {/* Sign Out */}
        <div className="mx-6 mb-6">
          <button className="w-full bg-red-500/20 text-red-400 rounded-xl p-4 font-medium">
            Sign Out
          </button>
        </div>
      </div>
    );
  };

  const ConditionCard = ({ icon, label, value, trend, optimal }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700">
      <div className="flex items-center justify-between mb-2">
        <div className="text-cyan-400">{icon}</div>
        {optimal && <div className="w-2 h-2 bg-green-400 rounded-full"></div>}
      </div>
      <p className="text-gray-400 text-sm mb-1">{label}</p>
      <p className="text-white text-xl font-semibold">{value}</p>
      <p className="text-gray-500 text-xs mt-1">{trend}</p>
    </div>
  );

  const ActivityCard = ({ title, description, time, type }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700 flex items-center">
      <div className={`w-10 h-10 rounded-full flex items-center justify-center mr-3 ${
        type === 'alert' ? 'bg-red-500/20' : 'bg-blue-500/20'
      }`}>
        {type === 'alert' ? 
          <AlertCircle className="w-5 h-5 text-red-400" /> :
          <TrendingUp className="w-5 h-5 text-blue-400" />
        }
      </div>
      <div className="flex-1">
        <h3 className="text-white font-medium">{title}</h3>
        <p className="text-gray-400 text-sm">{description}</p>
      </div>
      <div className="text-gray-500 text-xs">{time}</div>
    </div>
  );

  const TabButton = ({ icon, label, tabKey }) => (
    <button
      onClick={() => setActiveTab(tabKey)}
      className={`flex flex-col items-center py-2 px-4 rounded-lg transition-colors ${
        activeTab === tabKey 
          ? 'text-cyan-400' 
          : 'text-gray-400 hover:text-gray-300'
      }`}
    >
      {icon}
      <span className="text-xs mt-1">{label}</span>
    </button>
  );

  const MetricRow = ({ label, value, change, trend }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700 flex items-center justify-between">
      <span className="text-gray-400">{label}</span>
      <div className="flex items-center gap-2">
        <span className="text-white font-medium">{value}</span>
        <span className={`text-sm ${trend === 'up' ? 'text-green-400' : 'text-red-400'}`}>
          {change}
        </span>
      </div>
    </div>
  );

  const HistoricalEvent = ({ date, location, probability, confirmed }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700">
      <div className="flex items-center justify-between mb-2">
        <span className="text-white font-medium">{date}</span>
        {confirmed && (
          <span className="text-xs bg-green-500/20 text-green-400 px-2 py-1 rounded">
            Confirmed
          </span>
        )}
      </div>
      <p className="text-gray-400 text-sm">{location}</p>
      <p className="text-gray-500 text-xs mt-1">Peak probability: {probability}</p>
    </div>
  );

  const SettingToggle = ({ label, description, value, onChange }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700 flex items-center justify-between">
      <div className="flex-1">
        <p className="text-white">{label}</p>
        <p className="text-gray-400 text-sm">{description}</p>
      </div>
      <button
        onClick={() => onChange(!value)}
        className={`w-12 h-6 rounded-full transition-colors ${
          value ? 'bg-cyan-500' : 'bg-gray-600'
        }`}
      >
        <div className={`w-5 h-5 bg-white rounded-full transition-transform ${
          value ? 'translate-x-6' : 'translate-x-0.5'
        }`} />
      </button>
    </div>
  );

  const SettingRow = ({ label, value, hasArrow }) => (
    <div className="bg-gray-800 rounded-xl p-4 border border-gray-700 flex items-center justify-between">
      <span className="text-white">{label}</span>
      <div className="flex items-center gap-2">
        {value && <span className="text-gray-400">{value}</span>}
        {hasArrow && <ChevronRight className="w-5 h-5 text-gray-400" />}
      </div>
    </div>
  );

  return (
    <div className="w-full max-w-md mx-auto h-screen bg-gray-900 text-white flex flex-col relative">
      {/* Status Bar */}
      <div className="bg-black px-6 py-2 flex justify-between items-center text-xs">
        <span>9:41 AM</span>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 border border-white rounded-sm"></div>
          <div className="w-4 h-4 border border-white rounded-sm"></div>
          <div className="w-4 h-4 bg-white rounded-sm"></div>
        </div>
      </div>

      {/* Main Content */}
      {activeTab === 'dashboard' && <Dashboard />}
      {activeTab === 'community' && <Community />}
      {activeTab === 'map' && <MapView />}
      {activeTab === 'trends' && <Trends />}
      {activeTab === 'settings' && <SettingsView />}

      {/* Bottom Navigation */}
      <div className="absolute bottom-0 left-0 right-0 bg-gray-800 border-t border-gray-700">
        <div className="flex justify-around items-center py-2">
          <TabButton icon={<Home className="w-6 h-6" />} label="Dashboard" tabKey="dashboard" />
          <TabButton icon={<MessageCircle className="w-6 h-6" />} label="Community" tabKey="community" />
          <TabButton icon={<Map className="w-6 h-6" />} label="Map" tabKey="map" />
          <TabButton icon={<TrendingUp className="w-6 h-6" />} label="Trends" tabKey="trends" />
          <TabButton icon={<Settings className="w-6 h-6" />} label="Settings" tabKey="settings" />
        </div>
      </div>
    </div>
  );
};

export default JubileeApp;