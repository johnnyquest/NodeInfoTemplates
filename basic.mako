<%namespace name="ni" module="nodegraphinfo"/>

<style>
    p { margin: 0; padding: 0;}
</style>

<p id="nodepath" style="color: #888; font-size: smaller;">
${infoitem.path().rsplit('/', 1)[0] + '/'}
</p>

<p id="nodename" style="font-weight: bold; color: white; font-size: x-large;">
${infoitem.name()}
</p>

<p id="nodetype" style="color: #888; margin-top: 3px;">
    ${ infoitem.type().description() }
    ${ infoitem.type().category().name() }
    (${infoitem.type().name()})
</p>
