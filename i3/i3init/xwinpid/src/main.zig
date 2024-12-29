// Adapted from:
// https://stackoverflow.com/questions/37283179/python-pid-to-x11-window-id-using-xresqueryclientids

const std = @import("std");

const flags = @import("flags");

const c = @cImport({
    @cInclude("xcb/xcb.h");
    @cInclude("xcb/res.h");
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var args = try std.process.argsWithAllocator(gpa.allocator());
    defer args.deinit();
    const window_id_str = flags.parseOrExit(&args, "xwinpid", Flags, .{}).positional.window_id;
    var window_id: u32 = undefined;
    if (std.mem.eql(u8, window_id_str[0..2], "0x")) {
        window_id = try std.fmt.parseInt(u32, window_id_str[2..], 16);
    } else {
        window_id = try std.fmt.parseInt(u32, window_id_str, 10);
    }

    var screen: i32 = undefined;
    const conn: *c.xcb_connection_t = c.xcb_connect(null, &screen) orelse unreachable;

    var spec: c.xcb_res_client_id_spec_t = .{
        .client = window_id,
        .mask = c.XCB_RES_CLIENT_ID_MASK_LOCAL_CLIENT_PID,
    };
    const cookie: c.xcb_res_query_client_ids_cookie_t = c.xcb_res_query_client_ids(conn, 1, &spec);
    var err: [*c]c.xcb_generic_error_t = undefined;
    const reply: *c.xcb_res_query_client_ids_reply_t = c.xcb_res_query_client_ids_reply(conn, cookie, &err);

    var pid: ?u32 = null;
    var it: c.xcb_res_client_id_value_iterator_t = c.xcb_res_query_client_ids_ids_iterator(reply);
    while (it.rem > 0) : (c.xcb_res_client_id_value_next(&it)) {
        spec = it.data.*.spec;
        if (spec.mask & c.XCB_RES_CLIENT_ID_MASK_LOCAL_CLIENT_PID > 0) {
            pid = c.xcb_res_client_id_value_value(it.data).*;
            break;
        }
    }

    std.c.free(reply);
    c.xcb_disconnect(conn);

    const stdout_file = std.io.getStdOut().writer();
    const stderr_file = std.io.getStdErr().writer();
    var bw_stdout = std.io.bufferedWriter(stdout_file);
    const stdout = bw_stdout.writer();
    var bw_stderr = std.io.bufferedWriter(stderr_file);
    const stderr = bw_stderr.writer();

    if (pid) |pid_value| {
        try stdout.print("{}\n", .{pid_value});
        try bw_stdout.flush();
    } else {
        try stderr.print("PID of window 0x{x} not found\n", .{window_id});
        try bw_stderr.flush();
    }
}

const Flags = struct {
    positional: struct {
        window_id: []const u8,

        pub const descriptions = .{
            .window_id = "id of the X11 window (required)",
        };
    },
};
