<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<%
    ropinfo = info.branches().get('ROP Info')
%>

${ self.properties(ropinfo) }
