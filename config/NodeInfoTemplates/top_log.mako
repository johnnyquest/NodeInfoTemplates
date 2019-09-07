<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
</style>

% if log is not None:
    <a href="showlog:false">Hide log</a>
    <pre>${log | h}</pre>
% else:
    <a href="showlog:true">Show log</a>
% endif
