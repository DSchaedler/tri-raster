def tick(args)
  args.gtk.log_level = :off

  tick_zero(args) if args.state.tick_count.zero?

  args.outputs.sprites << { x: args.grid.left, y: args.grid.bottom, w: args.grid.w, h: args.grid.h, path: :triangle }.sprite!

  reset_button(args)

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def tick_zero(args)
  triangle = pick_vertecies(args)
  triangle = triangle.sort_by { |point| point[1] }
  triangle = triangle.reverse

  line_slope = args.geometry.line_slope [triangle[0][0], triangle[0][1], triangle[2][0], triangle[2][1]]
  x_intercept = triangle[0][1] - (line_slope * triangle[0][0])

  vertex_4 = [(triangle[1][1] - x_intercept) / line_slope, triangle[1][1]]

  # /\
  leg_0 = [triangle[0], triangle[1]]
  leg_0_slope = args.geometry.line_slope([leg_0[0][0], leg_0[0][1], leg_0[1][0], leg_0[1][1]])
  leg_0_intercept = triangle[0][1] - (leg_0_slope * triangle[0][0])

  leg_1 = [triangle[0], vertex_4]
  leg_1_slope = args.geometry.line_slope([leg_1[0][0], leg_1[0][1], leg_1[1][0], leg_1[1][1]])
  leg_1_intercept = triangle[0][1] - (leg_1_slope * triangle[0][0])

  # \/
  leg_2 = [triangle[2], triangle[1]]
  leg_2_slope = args.geometry.line_slope([leg_2[0][0], leg_2[0][1], leg_2[1][0], leg_2[1][1]])
  leg_2_intercept = triangle[2][1] - (leg_2_slope * triangle[2][0])

  leg_3 = [triangle[2], vertex_4]
  leg_3_slope = args.geometry.line_slope([leg_3[0][0], leg_3[0][1], leg_3[1][0], leg_3[1][1]])
  leg_3_intercept = triangle[2][1] - (leg_3_slope * triangle[2][0])

  y_iter = triangle[0][1]
  while y_iter >= vertex_4[1]
    args.render_target(:triangle).lines << {
      x: (y_iter - leg_0_intercept) / leg_0_slope,
      y: y_iter,
      x2: (y_iter - leg_1_intercept) / leg_1_slope,
      y2: y_iter
    }.line!
    y_iter -= 1
  end

  y_iter = triangle[2][1]
  while y_iter >= vertex_4[1]
    args.render_target(:triangle).lines << {
      x: (y_iter - leg_0_intercept) / leg_0_slope,
      y: y_iter,
      x2: (y_iter - leg_1_intercept) / leg_1_slope,
      y2: y_iter
    }.line!
    y_iter += 1
  end
end

def pick_vertecies(args)
  point = []
  point[0] = [(0..args.grid.w).to_a.sample, (0..args.grid.h).to_a.sample]
  point[1] = [(0..args.grid.w).to_a.sample, (0..args.grid.h).to_a.sample]
  point[2] = [(0..args.grid.w).to_a.sample, (0..args.grid.h).to_a.sample]
  point
end

def reset_button(args)
  button_box = { x: args.grid.center_x - 50, y: args.grid.top - 50, w: 100, h: 50 }
  args.outputs.borders << button_box
  args.outputs.labels << { x: args.grid.center_x, y: args.grid.top - 15, text: 'Reset', alignment_enum: 1 }

  $gtk.reset seed: Time.now.to_i if args.inputs.mouse.up.inside_rect? button_box
end
