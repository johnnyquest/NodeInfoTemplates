<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%
    branches = info.branches()
    d = dict(branches.get('Dependency').rows())
%>

<span class="timedep">Time Dependent</span>
<span class="value">${ d["Time Dependent"] }</span>

%if "OBJ Info" in branches:
    <span class="timedep">Time Dependent Display</span>
    <span class="value">${ dict(branches["OBJ Info"].rows())["Time Dependent Display"] }</span>
%endif
