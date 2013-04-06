*** Settings ***

Documentation  This library expects jQuery to be found from the tested page.

Library  String
Library  Collections
Library  plone.app.robotframework.Annotate

*** Variables ***

${CROP_MARGIN} =  10

*** Keywords ***

Normalize annotation locator
    [Arguments]  ${locator}
    ${locator} =  Replace string  ${locator}  '  \\'
    ${locator} =  Replace string using regexp  ${locator}  ^jquery=  ${empty}
    ${locator} =  Replace string using regexp  ${locator}  ^css=  ${empty}
    [return]  ${locator}

Add dot
    [Arguments]  ${locator}  ${display}=block
    ${selector} =  Normalize annotation locator  ${locator}
    ${display} =  Replace string  ${display}  '  \\'
    ${id} =  Execute Javascript
    ...    return (function(){
    ...        var id = 'id' + Math.random().toString().substring(2);
    ...        var annotation = jQuery('<div></div>');
    ...        var target = jQuery('${selector}');
    ...        var offset = target.offset();
    ...        var height = target.height();
    ...        var width = target.width();
    ...        annotation.attr('id', id);
    ...        annotation.css({
    ...            'display': '${display}',
    ...            '-moz-box-sizing': 'border-box',
    ...            '-webkit-box-sizing': 'border-box',
    ...            'box-sizing': 'border-box',
    ...            'position': 'absolute',
    ...            'color': 'white',
    ...            'background': 'black',
    ...            'width': '20px',
    ...            'height': '20px',
    ...            'border-radius': '10px',
    ...            'top': (offset.top + height / 2 - 10).toString() + 'px',
    ...            'left': (offset.left + width / 2 - 10).toString() + 'px',
    ...            'z-index': '9999',
    ...        });
    ...        jQuery('body').append(annotation);
    ...        return id;
    ...    })();
    [return]  ${id}


Add note
    [Arguments]  ${locator}  ${sleep}  ${message}
    ...          ${background}=white
    ...          ${color}=black
    ...          ${border}=1px solid black
    ...          ${display}=block
    ${selector} =  Normalize annotation locator  ${locator}
    ${message} =  Replace string  ${message}  '  \\'
    ${background} =  Replace string  ${background}  '  \\'
    ${color} =  Replace string  ${color}  '  \\'
    ${border} =  Replace string  ${border}  '  \\'
    ${display} =  Replace string  ${display}  '  \\'
    ${id} =  Execute Javascript
    ...    return (function(){
    ...        var id = 'id' + Math.random().toString().substring(2);
    ...        var annotation = jQuery('<div></div>');
    ...        var target = jQuery('${selector}');
    ...        var offset = target.offset();
    ...        var width = target.width();
    ...        var height = target.height();
    ...        annotation.attr('id', id);
    ...        annotation.text('${message}');
    ...        annotation.css({
    ...            'display': '${display}',
    ...            'position': 'absolute',
    ...            '-moz-box-sizing': 'border-box',
    ...            '-webkit-box-sizing': 'border-box',
    ...            'box-sizing': 'border-box',
    ...            'padding': '0.5ex 0.5em',
    ...            'border-radius': '1ex',
    ...            'border': '${border}',
    ...            'background': '${background}',
    ...            'color': '${color}',
    ...            'z-index': '9999',
    ...            'width': '100px',
    ...            'top': (offset.top + height / 2).toString() + 'px',
    ...            'left': (offset.left + width / 2 - 50).toString() + 'px',
    ...        });
    ...        jQuery('body').append(annotation);
    ...        return id;
    ...    })();
    [return]  ${id}

Remove element
    [Arguments]  ${id}
    Execute Javascript
    ...    return (function(){
    ...        jQuery('#${id}').remove();
    ...        return true;
    ...    })();

Update element style
    [Arguments]  ${id}  ${name}  ${value}
    ${name} =  Replace string  ${name}  '  \\'
    ${value} =  Replace string  ${value}  '  \\'
    Execute Javascript
    ...    return (function(){
    ...        jQuery('#${id}').css({
    ...            '${name}': '${value}'
    ...        });
    ...        return true;
    ...    })();
    [return]  ${id}

Crop page screenshot
    [Arguments]  ${filename}  @{locators}
    @{selectors} =  Create list
    :FOR  ${locator}  IN  @{locators}
    \  ${selector} =  Normalize annotation locator  ${locator}
    \  Append to list  ${selectors}  ${selector}
    ${selectors} =  Convert to string  ${selectors}
    ${selectors} =  Replace string using regexp  ${selectors}  u'  '
    @{dimensions} =  Execute Javascript
    ...    return (function(){
    ...        var selectors = ${selectors}, i, target, offset;
    ...        var left = 0, top = 0, width = 0, height = 0;
    ...        for (i = 0; i < selectors.length; i++) {
    ...            target = jQuery(selectors[i]);
    ...            offset = target.offset();
    ...            if (left === null) { left = offset.left; }
    ...            else { left = Math.min(left, offset.left); }
    ...            if (top === null) { top = offset.top; }
    ...            else { top = Math.min(top, offset.top); }
    ...            if (width === null) { width = target.outerWidth(); }
    ...            else {
    ...                width = Math.max(
    ...                    left + width, offset.left + target.outerWidth()
    ...                ) - left;
    ...             }
    ...            if (height === null) { height = target.outerHeight(); }
    ...            else {
    ...                height = Math.max(
    ...                    top + height, offset.top + target.outerHeight()
    ...                ) - top;
    ...            }
    ...        }
    ...        return [left - ${CROP_MARGIN},
    ...                top - ${CROP_MARGIN},
    ...                width + ${CROP_MARGIN} * 2,
    ...                height + ${CROP_MARGIN} * 2];
    ...    })();
    Crop image  ${filename}  @{dimensions}