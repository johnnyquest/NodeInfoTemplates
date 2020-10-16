<%namespace name="ni" module="nodegraphinfo"/>
<%namespace name="it" module="itertools"/>
<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
p { margin: 0; padding: 0;}
</style>

<%
	state_label = "Cooking"
	if state == pdg.workItemState.CookedSuccess:
		state_label = "Cooked"
	elif state == pdg.workItemState.CookedCache:
		state_label = "Cooked from Cache"
	elif state == pdg.workItemState.CookedFail:
		state_label = "Failed"
	elif state == pdg.workItemState.CookedCancel:
		state_label = "Canceled"
	elif state == pdg.workItemState.Uncooked:
		state_label = "Dirty"
	elif state == pdg.workItemState.Dirty:
		state_label = "Dirty"
%>

<p>
    ${node_name}
</p>

<p id="workitemname" style="font-weight: bold; color: white; font-size: x-large;">
${name}
</p>

<p>
    Task
</p>
