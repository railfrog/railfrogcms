/**
 * @author Ryan Johnson <ryan@livepipe.net>
 * @copyright 2007 LivePipe LLC
 * @package Object.Event
 * @license MIT
 * @url http://livepipe.net/projects/object_event/
 * @version 1.0.0
 */

Object.Event = {
	extend: function(object){
		object._objectEventSetup = function(event_name){
			this._observers = this._observers || {};
			this._observers[event_name] = this._observers[event_name] || [];
		};
		object.observe = function(event_name,observer){
			if(typeof(event_name) == 'string' && typeof(observer) != 'undefined'){
				this._objectEventSetup(event_name);
				if(!this._observers[event_name].include(observer))
					this._observers[event_name].push(observer);
			}else
				for(var e in event_name)
					this.observe(e,event_name[e]);
		};
		object.stopObserving = function(event_name,observer){
			this._objectEventSetup(event_name);
			this._observers[event_name] = this._observers[event_name].without(observer);
		};
		object.notify = function(event_name){
			this._objectEventSetup(event_name);
			var collected_return_values = [];
			var args = $A(arguments).slice(1);
			try{
				for(var i = 0; i < this._observers[event_name].length; ++i)
					collected_return_values.push(this._observers[event_name][i].apply(this._observers[event_name][i],args) || null);
			}catch(e){
				if(e == $break)
					return false;
				else
					throw e;
			}
			return collected_return_values;
		};
		if(object.prototype){
			object.prototype._objectEventSetup = object._objectEventSetup;
			object.prototype.observe = object.observe;
			object.prototype.stopObserving = object.stopObserving;
			object.prototype.notify = function(event_name){
				if(object.notify){
					var args = $A(arguments).slice(1);
					args.unshift(this);
					args.unshift(event_name);
					object.notify.apply(object,args);
				}
				this._objectEventSetup(event_name);
				var args = $A(arguments).slice(1);
				var collected_return_values = [];
				try{
					if(this.options && this.options[event_name] && typeof(this.options[event_name]) == 'function')
						collected_return_values.push(this.options[event_name].apply(this,args) || null);
					for(var i = 0; i < this._observers[event_name].length; ++i)
						collected_return_values.push(this._observers[event_name][i].apply(this._observers[event_name][i],args) || null);
				}catch(e){
					if(e == $break)
						return false;
					else
						throw e;
				}
				return collected_return_values;
			};;
		}
	}
};