const std = @import("std");
// const options = @import("options");
const options = struct {
    const metricPrefixCompress = false;
};

pub fn generateMetricPrefix(
    comptime T: type,
    comptime expansionEnum: type,
    comptime abbreviationEnum: type,
    factorBase: u8,
    factorPower: [] const i8,
) type {
    if (options.metricPrefixCompress) {
        return struct {
            pub const expansion = expansionEnum;
            pub const abbreviation = abbreviationEnum;

            pub const base = factorBase;
            pub const power = factorPower;
            
            pub fn getNum(comptime E: type, e: E) T {
                return std.math.pow(T, base, power[@intFromEnum(e)]);
            }
            pub fn getEnum(number: T) struct { expansion, abbreviation } {
                const log = std.math.log(T, base, number);
                const index = std.mem.indexOf(T, power, [_]T {log});
                return .{ @enumFromInt(index), @enumFromInt(index)};
            }
        };
    } else {
        return struct {
            pub const expansion = expansionEnum;
            pub const abbreviation = abbreviationEnum;

            pub const factor = blk: {
                var result: [factorPower.len]T = undefined;
                for (factorPower, 0..) |pow,i| {
                    result[i] = std.math.pow(T, factorBase, pow);
                }
                break :blk result;
            };

            pub fn getNum(comptime E: type, e: E) T {
                return factor[@intFromEnum(e)];
            }
            pub fn getEnum(number: T) struct { expansion, abbreviation } {
                const index = std.mem.indexOf(T, factor, [_]T {number});
                return .{ @enumFromInt(index), @enumFromInt(index) };
            }
        };
    }
}

const _SI = struct {
    const expansion = enum {
        quetta,
        ronna,
        yotta,
        zetta,
        exa,
        peta,
        tera,
        giga,
        mega,
        kilo,
        hecto,
        deca,
        none,
        deci,
        centi,
        milli,
        micro,
        nano,
        pico,
        femto,
        atto,
        zepto,
        yocto,
        ronto,
        quecto,
    };
    const abbreviation = enum {
        Q,
        R,
        Y,
        Z,
        E,
        P,
        T,
        G,
        M,
        k,
        h,
        da,
        NA,
        d,
        c,
        m,
        u,
        n,
        p,
        f,
        a,
        z,
        y,
        r,
        q,
    };
    const factorBase = 10;
    const factorPower = [_] i8 {
        30,
        27,
        24,
        21,
        18,
        15,
        12,
        9,
        6,
        3,
        2,
        1,
        0,
        -1,
        -2,
        -3,
        -6,
        -9,
        -12,
        -15,
        -18,
        -21,
        -24,
        -27,
        -30,
    };
};

pub const SI = generateMetricPrefix(
    f64,
    _SI.expansion,
    _SI.abbreviation,
    _SI.factorBase,
    &_SI.factorPower,
);

const _IEC = struct {
    const expansion = enum {
        yobi,
        zebi,
        exbi,
        pebi,
        tebi,
        gibi,
        mebi,
        kibi,
        none,
    };
    const abbreviation = enum {
        Yi,
        Zi,
        Ei,
        Pi,
        Ti,
        Gi,
        Mi,
        Ki,
        NA,
    };
    const factorBase = 2;
    const factorPower = [_] i8 {
        80,
        70,
        60,
        50,
        40,
        30,
        20,
        10,
        0
    };
};

pub const IEC = generateMetricPrefix(
    f32,
    _IEC.expansion,
    _IEC.abbreviation, 
    _IEC.factorBase,
    &_IEC.factorPower
);

test "expected quetta" {
    try std.testing.expect(SI.getNum(SI.expansion, .kilo));
}
