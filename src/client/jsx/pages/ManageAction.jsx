/** @jsx React.DOM */

// CommonJS, AMD, and Global shim
(function (root, factory) {
    'use strict';
	if (typeof exports === "object") {
		// CommonJS
		module.exports = exports = factory(
            require('react')
        );
	}
	else if (typeof define === "function" && define.amd) {
		// AMD
		define([
            'react'
        ], factory);
	}
	else {
		// Global (browser)
		root.ManageAction = factory(root.React);
	}
}(this, function (React) {
    'use strict';
    return React.createClass({

        /*************************************************************
         * TYPES AND ENUMERATIONS
         *************************************************************/
        VIEW_MODE: {
            GENERAL: 'general',  
            HISTORY: 'history' 
        },
        
        /*************************************************************
         * COMPONENT LIFECYCLE
         *************************************************************/
        getInitialState: function () {
            return {
                viewMode: 'general',
                durationValue: null,
                durationDisplay: null,
                dateInput: null, 
                dateDisplay: null,
                repeat: 'o',
                repeatInterval: 1,
                repeatSun: false,
                repeatMon: false,
                repeatTue: false,
                repeatWed: false,
                repeatThu: false,
                repeatFri: false,
                repeatSat: false
            };  
        },

        componentWillReceiveProps: function (nextProps) {
            if (!nextProps.action) {
                // get tags from UI filter
                var tags = ui.tags || [];
                tags = tags.slice(); //copy
                tags.push(this.props.focusTag);

                // create a new action
                nextProps.action = new hlapp.ToDo('New ToDo', tags);
                nextProps.action.name = null;
                nextProps.action.enlist = new Date();
            } else {
                nextProps.action = this.edit(nextProps.action);
            }
        },
        componentWillMount: function () {
            
            if (!this.props.action) {
                // get tags from UI filter
                var tags = ui.tags || [];
                tags = tags.slice(); //copy
                tags.push(this.props.focusTag);

                // create a new action
                this.props.action = new hlapp.ToDo('New ToDo', tags);
                this.props.action.name = null;
                this.props.action.enlist = new Date();
            } else {
                this.props.action = this.edit(this.props.action);
            }
            
            var detailsChange = EventHandler.create();
            detailsChange
                .throttle(1000)
                .subscribe(this.handleDetailsChange);

            this.handlers = {
                detailsChange: detailsChange
            };
        },
        componentWillUnmount: function () {
            /**
             * Clean up objects and bindings
             */
            this.handlers.detailsChange.dispose();
        },

        componentDidMount: function () {
            this.setupTagsControl();
            
            var resizeTextArea = function () {
                if (Math.abs($(this).height() - this.scrollHeight) > 16) {
                    $(this).height(0).height(this.scrollHeight);
                }
            };
            
            $(this.refs.content.getDOMNode()).on( 'change keyup keydown paste cut', resizeTextArea).change();
            
            if (this.props.mode === 'Add') {
                $(this.refs.name.getDOMNode()).focus();
            }
        },

        /*************************************************************
         * API
         *************************************************************/
        edit: function (action) {
            // create a copy of the action for editing
            var editableCopy = {};
            Object.assign(editableCopy, action);

            // flag to call modal's graceful open dialog function
            this.show = true;

            var durationParse = babble.get('durations').translate(editableCopy.duration + ' min');
            if (durationParse.tokens.length === 0) {
                var durationValue = null;
            } else {
                var durationValue = durationParse.tokens[0].value.toString();
            }

            if (action.nextDate === null || String(action.nextDate) === 'NaN') {
                var date = null;
            } else {
                var date = action.nextDate.toLocaleDateString();
            }

            // build state
            var state = {
                durationValue: durationValue,
                durationDisplay: null,
                dateInput: date, 
                dateDisplay: null,
                mode: 'Edit',
                repeat: 'o',
                repeatInterval: 1,
                repeatSun: false,
                repeatMon: false,
                repeatTue: false,
                repeatWed: false,
                repeatThu: false,
                repeatFri: false,
                repeatSat: false
            };

            if (action.recurrenceRules.length > 0) {
                var recurrenceObj = hlapp.getRecurrenceObj(action.recurrenceRules[0]);
                state.repeat = recurrenceObj.freq.slice(0,1).toLowerCase();
                state.repeatInterval = recurrenceObj.interval;
                if (recurrenceObj.byday) {
                    for (var i = 0; i < recurrenceObj.byday.length; i++) {
                        if (recurrenceObj.byday[i].day === 'SU') {
                            state.repeatSun = true;
                        }
                        if (recurrenceObj.byday[i].day === 'MO') {
                            state.repeatMon = true;
                        }
                        if (recurrenceObj.byday[i].day === 'TU') {
                            state.repeatTue = true;
                        }
                        if (recurrenceObj.byday[i].day === 'WE') {
                            state.repeatWed = true;
                        }
                        if (recurrenceObj.byday[i].day === 'TH') {
                            state.repeatThu = true;
                        }
                        if (recurrenceObj.byday[i].day === 'FR') {
                            state.repeatFri = true;
                        }
                        if (recurrenceObj.byday[i].day === 'SA') {
                            state.repeatSat = true;
                        }
                    }
                }
            }

            // set state
            this.setState(state);
            
            return editableCopy;
        },

        /*************************************************************
         * BINDINGS
         *************************************************************/
        setOptions: function (selectize) {
            // clear previously set options
            selectize.clearOptions();

            // get distinct tags user has assigned to other actions
            var actions = actionStore.updates.value;
            var distinctTags = [];
            actions.map(function(item) {
                distinctTags = _.union(distinctTags, item.tags);
            });
            // { kind: 'Tag', name: tag }
            // add tags that user has assigned to other actions
            distinctTags.forEach( function (tag) {

                selectize.addOption(hlapp.parseTag(tag));
            });
        },
        setupTagsControl: function () {
            if (this.props.action) {
                // initialize control for tags functionality
                $(this.refs.tags.getDOMNode()).selectize({
                    delimiter: ',',
                    persist: true,
                    valueField: 'value',
                    labelField: 'name',
                    searchField: ['name', 'kind'],
                    render: {
                        item: function(item, escape) {
                            return '<div class="item"><i class="fa ' + item.className + '"></i> ' + escape(item.name) + '</div>';
                        },
                        option: function(item, escape) {
                            var label = item.name || item.kind;
                            var caption = item.kind ? item.kind : null;
                            return '<div>' +
                                '<span class="label">' + escape(label) + '</span>' +
                                (caption ? '<span class="caption">' + escape(caption) + '</span>' : '') +
                            '</div>';
                        }
                    },
                    create: function(input) {
                        return hlapp.parseTag(input);
                    }
                });

                // populate existing tag options
                var selectize = $(this.refs.tags.getDOMNode())[0].selectize;
                this.setOptions(selectize);

                // set current value
                if (this.props.action) {
                    selectize.setValue(this.props.action.tags);
                }
            }
        },

        /*************************************************************
         * EVENT HANDLING
         *************************************************************/
        handleChange: function (event) {
            if (event.target === this.refs.name.getDOMNode()) {
                this.props.action.name = event.target.value;
            } else if (event.target === this.refs.content.getDOMNode()) {
                this.props.action.content = event.target.value;
            } else if (event.target === this.refs.duration.getDOMNode()) {
                var durationParsed = babble.get('durations').translate(this.refs.duration.getDOMNode().value.trim());
                var duration = 0
                var durationDisplay = '';
                if (durationParsed.tokens.length > 0) {
                    duration = durationParsed.tokens[0].value.toMinutes();
                    durationDisplay = durationParsed.tokens[0].value.toString('minutes');
                }

                this.props.action.duration = duration;
                this.state.durationValue = this.refs.duration.getDOMNode().value;
                this.state.durationDisplay = durationDisplay;
            } else if (event.target === this.refs.repeat.getDOMNode()) {
                this.state.repeat = event.target.value;
            } else if (event.target === this.refs.nextdate.getDOMNode()) {

                var dateValue = Date.create(event.target.value);
                var dateDisplay = '';
                try {
                    dateDisplay = dateValue.toISOString();
                } catch (e) {
                    if (e instanceof RangeError) {
                        dateValue = null;
                    } else {
                        throw e;   
                    }
                }

                if (dateValue !== null) {
                    if (dateValue.getHours() === 0 && dateValue.getMinutes() === 0) {
                        dateDisplay = dateValue.toLocaleDateString();
                    } else {
                        dateDisplay = dateValue.toLocaleDateString() + ' ' + dateValue.toLocaleTimeString();
                    }
                }

                this.props.action.nextdate = dateValue;
                this.setState({dateInput: event.target.value, dateDisplay: dateDisplay});

                this.props.action.nextDate = event.target.value;
            } else if (this.refs.repeatInterval && event.target === this.refs.repeatInterval.getDOMNode()) {
                this.state.repeatInterval = parseInt(event.target.value);
            } else if (this.refs.repeatSun && event.target === this.refs.repeatSun.getDOMNode()) {
                this.state.repeatSun = event.target.checked;
            } else if (this.refs.repeatMon && event.target === this.refs.repeatMon.getDOMNode()) {
                this.state.repeatMon = event.target.checked;
            } else if (this.refs.repeatTue && event.target === this.refs.repeatTue.getDOMNode()) {
                this.state.repeatTue = event.target.checked;
            } else if (this.refs.repeatWed && event.target === this.refs.repeatWed.getDOMNode()) {
                this.state.repeatWed = event.target.checked;
            } else if (this.refs.repeatThu && event.target === this.refs.repeatThu.getDOMNode()) {
                this.state.repeatThu = event.target.checked;
            } else if (this.refs.repeatFri && event.target === this.refs.repeatFri.getDOMNode()) {
                this.state.repeatFri = event.target.checked;
            } else if (this.refs.repeatSat && event.target === this.refs.repeatSat.getDOMNode()) {
                this.state.repeatSat = event.target.checked;
            }
            this.setState({ 
                action: this.props.action,
                durationValue: this.state.durationValue,
                durationDisplay: this.state.durationDisplay,
                repeat: this.state.repeat,
                repeatInterval: this.state.repeatInterval,
                repeatSun: this.state.repeatSun,
                repeatMon: this.state.repeatMon,
                repeatTue: this.state.repeatTue,
                repeatWed: this.state.repeatWed,
                repeatThu: this.state.repeatThu,
                repeatFri: this.state.repeatFri,
                repeatSat: this.state.repeatSat
            });
        },
        handleCancelClick: function(event) {
            window.ui.goBack();
        },
        handleDeleteClick: function() {
            actionStore.destroy(this.props.action);
            ui.goBack();
        },
        handleDetailsChange: function(event) {
            for (var i = 0; i < this.props.action.logEntries.length; i++) {
                if (this.props.action.logEntries[i].id === event.target.id) {
                    actionStore.updateLogEntry(this.props.action.logEntries[i], { details: event.target.value});
                    break;
                }
            }
        },
        handleToggleViewModeClick: function(event) {
            if (this.state.viewMode === 'general') {
                this.setState({ viewMode: 'history' });
            } else {
                this.setState({ viewMode: 'general' });
            }
        },
        handleSaveClick: function(event) {

            // set state of tags
            var tags = [];
            if (this.refs.tags.getDOMNode().value) {
                tags = this.refs.tags.getDOMNode().value.split(',');
            }
            this.props.action.tags = tags;

            // build recurrence rules
            var recurrenceRules = [];
            if (this.state.repeat === 'd') {
                var dailyRule = 'RRULE:FREQ=DAILY';
                if (this.state.repeatInterval > 1) {
                    dailyRule += ';INTERVAL=' + this.state.repeatInterval;    
                }
                recurrenceRules.push(dailyRule);
            } else if (this.state.repeat === 'w' && (
            this.state.repeatSun || 
            this.state.repeatMon ||
            this.state.repeatTue ||
            this.state.repeatWed ||
            this.state.repeatThu ||
            this.state.repeatFri ||
            this.state.repeatSat)) {

                var weeklyRule = 'RRULE:FREQ=WEEKLY;BYDAY=';
                var days = [];
                if (this.state.repeatSun) {
                    days.push('SU');   
                }
                if (this.state.repeatMon) {
                    days.push('MO');   
                }
                if (this.state.repeatTue) {
                    days.push('TU');   
                }
                if (this.state.repeatWed) {
                    days.push('WE');   
                }
                if (this.state.repeatThu) {
                    days.push('TH');   
                }
                if (this.state.repeatFri) {
                    days.push('FR');   
                }
                if (this.state.repeatSat) {
                    days.push('SA');   
                }
                weeklyRule += days.join(',');

                if (this.state.repeatInterval > 1) {
                    weeklyRule += ';INTERVAL=' + this.state.repeatInterval;    
                }
                recurrenceRules.push(weeklyRule);
            } else if (this.state.repeat === 'm') {
                var dailyRule = 'RRULE:FREQ=MONTHLY';
                if (this.state.repeatInterval > 1) {
                    dailyRule += ';INTERVAL=' + this.state.repeatInterval;    
                }
                recurrenceRules.push(dailyRule);
            }
            this.props.action.recurrenceRules = recurrenceRules;

            // build next date
            this.props.action.nextDate = babble.moments.parseLocalDate(this.props.action.nextDate);

            // call method to save the action
            if (this.props.mode === 'Edit') {
                actionStore.update({ actionRef: this.props.action.ref, state: this.props.action });
            } else {
                actionStore.create(this.props.action);
            }

            ui.goBack();
        },

        /*************************************************************
         * RENDERING
         *************************************************************/
        renderDayCheckbox: function (day) {
            var checkboxStyle = { display: 'inline-block', width: '34px' };
            var divStyle = { display: 'inline' };
            var labelStyle = {fontSize: '1.4rem', verticalAlign: 'super'};
            return (
                <div style={divStyle}>
                    <label style={labelStyle} htmlFor={'action-repeat-' + day.toLowerCase()}>{day.slice(0,1)}</label>
                    <input 
                        id={'action-repeat-' + day.toLowerCase()} 
                        ref={'repeat' + day}
                        type="checkbox" 
                        className="form-control" 
                        style={checkboxStyle} 
                        checked={this.state['repeat' + day]} 
                        onChange={this.handleChange} />
                </div>
            );
        },
        renderRepeatOptions: function () {
            var repeat = this.state.repeat;

            if (repeat === 'w') {

                /**
                 * Render day of week checkboxes in order 
                 * based on the user's start of week
                 */
                var dayIndex = userStore.updates.value.weekStarts;
                var daysOfWeek = [];
                while (daysOfWeek.length < 7) {
                    daysOfWeek.push(this.renderDayCheckbox(babble.moments.daysOfWeek[dayIndex].slice(0,3)));
                    dayIndex++;
                    if (dayIndex > 6) {
                        dayIndex = 0;   
                    }
                }

                return ([
                    <div className="form-group">
                        <label htmlFor="action-repeat-interval">Every</label>
                        <input id="action-repeat-interval" ref="repeatInterval" type="number" className="form-control" value={this.state.repeatInterval} onChange={this.handleChange} />
                        <label>Week(s)</label>
                    </div>,
                    <div className="form-group">
                        {daysOfWeek}
                    </div>
                ]);
            } else if (repeat === 'd' || repeat === 'm') {
                return (
                    <div className="form-group">
                        <label htmlFor="action-repeat-interval">Every</label>
                        <input id="action-repeat-interval" ref="repeatInterval" type="number" className="form-control" value={this.state.repeatInterval} onChange={this.handleChange} />
                        <label>{this.state.repeat === 'd' ? 'Day(s)' : 'Month(s)'}</label>
                    </div>
                );
            } else {
                return null;   
            }
        },
        renderGeneralView: function () {
            
            /**
             * State and Prop Dependencies
             */
            var action = this.props.action;
            var name = action.name || '';
            var content = action.content || '';
            var durationValue = this.state.durationValue;
            var dateInput = this.state.dateInput;

            /**
             * Sub Renders
             */
            var repeatOptions = this.renderRepeatOptions();

            /**
             * Render
             */
            return (
                <form role="form">
                    <div className="form-group">
                        <label htmlFor="action-name">Name</label>
                        <input id="action-name" ref="name" type="text" className="form-control" placeholder="Name of action" value={name} onChange={this.handleChange} />
                    </div>
                    <div className="form-group">
                        <label htmlFor="action-tags">Tags</label>
                        <input id="action-tags" ref="tags" type="text" />
                    </div>
                    <div className="form-group">
                        <label htmlFor="action-duration">How long do you think it will take?</label>
                        <input id="action-duration" ref="duration" type="text" className="form-control" value={durationValue} onChange={this.handleChange} />
                        <span>{this.state.durationDisplay}</span>
                    </div>
                    <div className="form-group">
                        <label htmlFor="action-repeat">How often will you do this?</label>
                        <select id="action-repeat" ref="repeat" className="form-control" value={this.state.repeat} onChange={this.handleChange}>
                            <option value="o">Once</option>
                            <option value="d">Daily</option>
                            <option value="w">Weekly</option>
                            <option value="m">Monthly</option>
                        </select>
                    </div>
                    {repeatOptions}
                    <div className="form-group">
                        <label htmlFor="action-content">Please add details here</label>
                        <textarea id="action-content" ref="content" type="text" className="form-control" value={content} onChange={this.handleChange} />
                    </div>
                    <div className="form-group">
                        <label htmlFor="action-nextdate">Hold off on this until</label>
                        <input id="action-nextdate" ref="nextdate" type="datetime" className="form-control" value={dateInput} onChange={this.handleChange} />
                        <span>{this.state.dateDisplay}</span>
                    </div>
                </form>
            ); 
        },
        renderHistoryView: function () {
            return (
                <div>
                    <h2 style={{ margin: '0 0 5px 5px'}}>Action History Log</h2>
                    <table className="table table-striped">
                        <tbody>                        
                            {this.props.action.logEntries.map(function(item, index) {
                                return (
                                    <tr key={item.id}>
                                        <td width="70px">{item.entry.slice(0,1).toUpperCase() + item.entry.slice(1)}</td>
                                        <td width="80px" style={{textAlign: 'right'}} >{item.date.toLocaleDateString()}</td>
                                        <td width="40px">{item.duration > 0 ? new babble.Duration(item.duration * 60000).toString(':') : ''}</td>
                                        <td><ContentEditable id={item.id} html={item.details} onChange={this.handlers.detailsChange} /></td>
                                    </tr>
                                );
                            }.bind(this))}
                        </tbody>
                    </table>
                </div>
            );
        },
        render: function () {

            /**
             * Render view based on the current view mode
             */
            var currentView = null,
                toggleTitle = null;
            if (this.state.viewMode === this.VIEW_MODE.GENERAL) {
                currentView = this.renderGeneralView();
                toggleTitle = 'View Action Log';
            } else if (this.state.viewMode === this.VIEW_MODE.HISTORY) {
                currentView = this.renderHistoryView();
                toggleTitle = 'View General';
            }
            
            /**
             * Buttons array to pass to Modal component
             */
            var buttons;

            if (this.props.mode === 'Add') {
                buttons = [{type: 'primary', 
                            text: 'Save Action',
                            handler: this.handleSaveClick},
                           {type: 'default', 
                            text: 'Cancel', 
                            handler: this.handleCancelClick},
                           ];
            }
            else {
                buttons = [{type: 'default', 
                            text: toggleTitle,
                            handler: this.handleToggleViewModeClick},
                           {type: 'primary', 
                            text: 'Save Changes',
                            handler: this.handleSaveClick},
                           {type: 'default', 
                            text: 'Cancel', 
                            handler: this.handleCancelClick}, 
                           {type: 'danger', 
                            text: 'Delete Action', 
                            handler: this.handleDeleteClick},
                           ];
            }
            
            var buttonStyle = {
              display: 'block',
              width: '100%',
              marginBottom: '5px',
              fontSize: '1.1rem'
            };
            var buttonsDom = buttons.map(function(button, index) {
                return <button key={index} style={buttonStyle} type="button" className={'btn btn-' + button.type} onClick={button.handler}>{button.text}</button>
            })

            /**
             * Render
             */
            return (
                <div style={{padding: '5px'}}>
                    <h2>{this.props.mode + ' Action'}</h2>
                    {currentView}
                    {buttonsDom}
                </div>
            );
        },
    });
}));