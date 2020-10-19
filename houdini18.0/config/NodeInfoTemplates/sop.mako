<%namespace name="ni" module="nodegraphinfo"/>
<%namespace name="it" module="itertools"/>
<%inherit file="geometry.mako"/>

<%def name="count_row(name, value, renames=None)">
    <%
        cls = name.lower()
    %>
    <tr>
        <td width="100" class="${cls} key">
            ${ renames.get(name, name) if renames else name }
        </td>
        <td class="${cls} value">
            <tt>${ ni.format_number(value) }</tt>
        </td>
    </tr>
</%def>

<%
    # vectors and hidden should be lists so we can + them
    vectors = ["Center", "Minimum", "Maximum", "Size"]
    # Memory is displayed in the "generic.mako" template, not here
    hidden = ["Memory",]

    # Branch information for the main node
    maininfobranches = maininfo.branches()
    maingeobranch = maininfobranches.get("SOP Info")
    mainlsysbranch = maininfobranches.get("L-System SOP Info")

    # If input node is provided, get its geometry branch
    if inputitem:
        inputinfobranches = inputinfo.branches()
        inputgeobranch = inputinfobranches.get("SOP Info")

    groups = [
        ('Point Groups', 'points'),
        ('Primitive Groups', 'primitives'),
        ('Primitive Groups (Mixed)', 'primitives'),
        ('Vertex Groups', 'vertices'),
        ('Edge Groups', 'edges'),
    ]
    attrs = [
        ('Point Attributes', 'points'),
        ('Primitive Attributes', 'primitives'),
        ('Vertex Attributes', 'vertices'),
        ('Detail Attributes', 'detail')
    ]
    renames = {
        "NURBS Surfaces": "NURBS Surfs",
        "Bezier Surfaces": "Bezier Surfs",
        "Bilinear Meshes": "Meshes",
        "Particle Systems": "Particle Sys",
        "Polygon Soups": "Poly Soups",
        "Minimum": "Min",
        "Maximum": "Max",
        "Primitive Groups": "Prim Groups",
        "Point Attributes": "Point Attrs",
        "Primitive Attributes": "Prim Attrs",
        "Vertex Attributes": "Vertex Attrs",
        "Detail Attributes": "Detail Attrs",
        "Packed Geometries": "Packed Geos",
    }
%>

% if maingeobranch:
    <%
        from itertools import chain
        from collections import defaultdict

        d = dict(maingeobranch.rows())
        mainbranches = maingeobranch.branches()
        maincountbranch = mainbranches.get("Counts")
        inputbranches = {}
        allbranches = defaultdict(list)
        if inputitem:
            inputbranches = inputgeobranch.branches()

        # Build a dictionary with the list of branches in both the main and 
        # input node
        for name, value in chain(mainbranches.items(), inputbranches.items()):
            allbranches[name].append(value)
            
        self.showdiffs = showdiffs
        self.attrdiffs = {"New Attrs": [], "Deleted Attrs": [], 
                            "Changed Attrs": []}
        self.mainbranches = mainbranches

        self.showattriblinks = showattriblinks

        # Builds self.attrdiffs based on the given attrdiffs, with the second 
        # element of each tuple being the attribute's branch name              
        if attrdiffs:
            for key in attrdiffs:
                for attr in attrdiffs[key]:
                    if attr[1] == "attribType.Point":
                        self.attrdiffs[key].append((attr[0], 
                                                    "Point Attributes"))
                    elif attr[1] == "attribType.Prim":
                        self.attrdiffs[key].append((attr[0], 
                                                    "Primitive Attributes"))
                    elif attr[1] == "attribType.Vertex":
                        self.attrdiffs[key].append((attr[0], 
                                                    "Vertex Attributes"))
                    else:
                        self.attrdiffs[key].append((attr[0],    
                                                    "Detail Attributes"))
    %>

    <table width="100%">
        <tr>
            <td width="50%">
                % if maincountbranch:
                    <table>
                        % for name, value in maincountbranch.rows():
                            ${ count_row(name, value, renames=renames) }
                        % endfor
                    </table>
                % endif
            </td>
            <td>
                <table>
                    % for name in vectors:
                        % if name in d and name not in hidden:
                            ${ self.vector_row(
                                name, d[name], renames=renames, keywidth='60'
                            ) }
                        % endif
                    % endfor
                </table>
            </td>
        </tr>
    </table>

    <table>
        ## Other properties
        ${ self.branch_rows(maingeobranch, recursive=False, hidden=hidden + vectors) }

        ## L-System program
        % if lsysbranch:
            ${ self.branch_rows(lsysbranch, cls="lsystem", tt=True, recursive=False) }
        % endif
    </table>

    ## Attributes
    ## Check if there are any branches in allbranches
    % if any((name in allbranches and mainbranches[name].rows()) \
    		for name, _ in attrs):
        <hr />
            <table>
                % for name, style in attrs:
                	## If the branch name is in the main and/or input node 
                	## branches, show the attributes of this branch
                    % if name in allbranches:
                        ${ self.show_attrs(allbranches, name, style, renames, verbose, debug) }
                    % endif
                % endfor
            </table>
    % endif

    ## Groups
    % if any((name in mainbranches) for name, _ in groups):
        <hr />
        <table>
            % for name, style in groups:
                % if name in mainbranches:
                    ${ self.show_groups(mainbranches, name, style, renames, verbose, debug) }
                % endif
            % endfor
        </table>
    % endif

    ## Volumes
    <%
        volbranch = mainbranches.get("Volumes")
        sparsebranch = mainbranches.get("Sparse Volumes")
    %>
    % if volbranch or sparsebranch:
        <hr />
        <table width="100%">
            % if volbranch:
                ## ${ ni.volume_rows_html(volbranch, "volumes", verbose) }
                ${ self.show_volumes(volbranch, "volumes", verbose) }
            % endif
            % if sparsebranch:
                ## ${ ni.volume_rows_html(volbranch, "vdbs", verbose) }
                ${ self.show_volumes(sparsebranch, "vdbs", verbose) }
            % endif
        </table>
    % endif
% endif

