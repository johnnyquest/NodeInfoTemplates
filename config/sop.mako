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

    infobranches = info.branches()
    geobranch = infobranches.get("SOP Info")
    lsysbranch = infobranches.get("L-System SOP Info")

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

% if geobranch:
    <%
        d = dict(geobranch.rows())
        branches = geobranch.branches()
        countbranch = branches.get("Counts")
    %>

    <table width="100%">
        <tr>
            <td width="50%">
                % if countbranch:
                    <table>
                        % for name, value in countbranch.rows():
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
        ${ self.branch_rows(geobranch, recursive=False, hidden=hidden + vectors) }

        ## L-System program
        % if lsysbranch:
            ${ self.branch_rows(lsysbranch, cls="lsystem", tt=True, recursive=False) }
        % endif
    </table>

    ## Attributes
    % if any((name in branches and branches[name].rows()) for name, _ in attrs):
        <hr />
        <table>
            % for name, style in attrs:
                % if name in branches:
                    ${ self.show_attrs(branches, name, style, renames, verbose, debug) }
                % endif
            % endfor
        </table>
    % endif

    ## Groups
    % if any((name in branches) for name, _ in groups):
        <hr />
        <table>
            % for name, style in groups:
                % if name in branches:
                    ${ self.show_groups(branches, name, style, renames, verbose, debug) }
                % endif
            % endfor
        </table>
    % endif

    ## Volumes
    <%
        volbranch = branches.get("Volumes")
        sparsebranch = branches.get("Sparse Volumes")
    %>
    % if volbranch or sparsebranch:
        <hr />
        <table width="100%">
            % if volbranch:
                ${ self.show_volumes(volbranch, "volumes", verbose) }
            % endif
            % if sparsebranch:
                ${ self.show_volumes(sparsebranch, "vdbs", verbose) }
            % endif
        </table>
    % endif
% endif

