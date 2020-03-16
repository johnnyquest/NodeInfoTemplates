<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%def name="show_messages(messages, severity)">
    % for message in messages:
        ${ self.kv_row(severity, message, cls=severity.lower())}
    % endfor
</%def>

<table>
    ${show_messages(errors, 'Error')}
    ${show_messages(warnings, 'Warning')}
    ${show_messages(messages, 'Message')}
</table>
